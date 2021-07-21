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
