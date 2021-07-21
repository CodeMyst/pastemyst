module pastemyst.request.router;

import std.traits;
import std.typecons;
import std.regex;
import vibe.d;

/**
 * Attribute specifying the route pattern.
 *
 * TODO: Specify the syntax.
 */
public struct Route
{
    ///
    string pattern;
}

/**
 * Type of route, api or web.
 */
public enum RouteType
{
    api,
    web,
}

/**
 * Attribute specifying that the function is an API route.
 */
public struct Api
{
    ///
    string ver;
}

/**
 * Attribute specifying that the function is web route.
 */
public struct Web {}

/**
 * Stores information about a route and its handler function.
 */
public struct RouteHandler
{
    ///
    string pattern;

    ///
    HTTPMethod method;

    ///
    RouteType routeType;

    /**
     * API version, only applicable if the route type is API.
     */
    string ver;

    /**
     * Handler delegate that executes the route.
     */
    RouteResponse delegate() handler;
}

/**
 * All route delegates are returning this struct.
 */
public struct RouteResponse
{
    ///
    Json json;

    /**
     * If the endpoint should be skipped, it will try and find the next mathing route,
     * if it can't find another route it will return 404.
     */
    bool skipped = false;
}

/**
 * Associative array <string, RouteHandler[]> of API routes.
 */
private RouteHandler[][string] apiRoutes;

/**
 * Register all API routes of a struct.
 */
public void registerApiRoutes(T)(T instance)
{
    import std.traits : getSymbolsByUDA, getUDAs;
    import std.algorithm : startsWith;

    /**
     * Loop over all functions of the instance and find ones with the proper attributes.
     */
    foreach (m; __traits(allMembers, T))
    {
        alias a = __traits(getMember, instance, m);
        if (isFunction!(a))
        {
            auto routeUdas = getUDAs!(a, Route);
            const apiUdas = getUDAs!(a, Api);

            if (routeUdas.length == 0 || apiUdas.length == 0) continue;

            auto pattern = routeUdas[0].pattern;
            auto ver = apiUdas[0].ver;

            auto method = HTTPMethod.GET;

            if (m.startsWith("get"))
            {
                method = HTTPMethod.GET;
            }
            else if (m.startsWith("post"))
            {
                method = HTTPMethod.POST;
            }

            auto handler = RouteHandler(pattern, method, RouteType.api, ver, toDelegate(&a));

            if (!(pattern in apiRoutes))
            {
                const RouteHandler[] tmp;
                apiRoutes[pattern] = cast(RouteHandler[]) tmp;
            }

            auto handlers = apiRoutes[pattern];
            handlers ~= handler;
            apiRoutes[pattern] = handlers;
        }
    }
}

/**
 * Returns all API handlers matching the pattern.
 */
public RouteHandler[] matchApiRoutes(HTTPServerRequest req)
{
    RouteHandler[] res;

    foreach (p, handlers; apiRoutes)
    {
        foreach (handler; handlers)
        {
            if (req.method != handler.method) continue;

            if (req.requestPath.toString() == ("/api/" ~ handler.ver ~ handler.pattern))
            {
                res ~= handler;
            }
        }
    }

    return res;
}

/**
 * Handles all vibe.d requests.
 */
public void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
{
    auto routes = matchApiRoutes(req);

    foreach (route; routes)
    {
        auto ret = route.handler();

        if (ret.skipped) continue;

        res.writeBody(ret.json.toPrettyString(), "application/json");

        return;
    }

    throw new HTTPStatusException(HTTPStatus.notFound);
}

@("Router")
unittest
{
    struct TestApi
    {
    public:

        @Api("v1")
        @Route("/test")
        RouteResponse getTest()
        {
            RouteResponse res;
            res.json = Json("test");
            return res;
        }

        @Api("v2")
        @Route("/test")
        RouteResponse postTest()
        {
            RouteResponse res;
            res.json = Json("");
            return res;
        }
    }

    registerApiRoutes(TestApi());

    assert(apiRoutes["/test"][0].ver == "v1");

    auto req = createTestHTTPServerRequest(URL("http://localhost:4000/api/v1/test"));

    auto routes = matchApiRoutes(req);

    assert(routes.length == 1);
    assert(routes[0].pattern == "/test");
    assert(routes[0].ver == "v1");
    assert(routes[0].method == HTTPMethod.GET);
    assert(routes[0].handler().json == Json("test"));

    req = createTestHTTPServerRequest(URL("http://localhost:4000/api/v2/test"), HTTPMethod.POST);

    routes = matchApiRoutes(req);

    assert(routes.length == 1);
    assert(routes[0].pattern == "/test");
    assert(routes[0].ver == "v2");
    assert(routes[0].method == HTTPMethod.POST);
    assert(routes[0].handler().json == Json(""));
}
