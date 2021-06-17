module pastemyst.request.router;

import std.traits;
import std.typecons;
import vibe.d;

public struct Route
{
    string value;
}

public struct RouteHandler
{
    Route route;
    Json delegate() handler;
}

private RouteHandler[] routeHandlers;

public void registerRoutes(T)(T instance)
{
    import std.traits : getSymbolsByUDA, getUDAs;

    foreach (m; __traits(allMembers, T))
    {
        alias a = __traits(getMember, instance, m);
        if (isFunction!(a))
        {
            auto udas = getUDAs!(a, Route);

            if (udas.length > 0)
            {
                auto route = udas[0];

                routeHandlers ~= RouteHandler(route, toDelegate(&a));
            }
        }
    }
}

public Nullable!RouteHandler matchRoute(string route)
{
    foreach (r; routeHandlers)
    {
        if (r.route.value == route)
        {
            return r.nullable;
        }
    }

    return Nullable!RouteHandler.init;
}
