module pastemyst.request.router;

import std.traits;
import std.typecons;
import std.regex;
import vibe.d;

public struct Route
{
    string value;
}

public struct Api
{
    string value;
}

public struct ApiRouteHandler
{
    Route route;
    Api api;
    Json delegate() handler;
}

private ApiRouteHandler[] apiRouteHandlers;

public void registerRoutes(T)(T instance)
{
    import std.traits : getSymbolsByUDA, getUDAs;

    foreach (m; __traits(allMembers, T))
    {
        alias a = __traits(getMember, instance, m);
        if (isFunction!(a))
        {
            auto routeUdas = getUDAs!(a, Route);
            auto apiUdas = getUDAs!(a, Api);

            if (routeUdas.length > 0 && apiUdas.length > 0)
            {
                auto route = routeUdas[0];
                auto api = apiUdas[0];

                apiRouteHandlers ~= ApiRouteHandler(route, api, toDelegate(&a));
            }
        }
    }
}

public Nullable!ApiRouteHandler matchApiRoute(string route)
{
    foreach (r; apiRouteHandlers)
    {
        if (route == ("/api/" ~ r.api.value ~ r.route.value))
        {
            return r.nullable;
        }
    }

    return Nullable!ApiRouteHandler.init;
}
