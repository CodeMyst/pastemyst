module pastemyst.web.base;

import vibe.d;

/++
 + adds a function for authentication of the current user
 +/
mixin template Auth()
{
    import pastemyst.data;

    @noRoute
    public UserSession authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe
    {
        if (!req.session || !req.session.isKeySet("user") || !req.session.get!UserSession("user").loggedIn)
        {
            res.redirect("/login");
            return UserSession.init;
        }

        return req.session.get!UserSession("user");
    }
}
