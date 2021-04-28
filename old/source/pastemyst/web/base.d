module pastemyst.web.base;

import vibe.d;

/++
 + adds a function for authentication of the current user
 +/
mixin template Auth()
{
    import pastemyst.data;
    import pastemyst.auth;

    @noRoute
    public Session authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe
    {
        const session = getSession(req);
        const user = session.getSessionUser();

        if (session == Session.init)
        {
            res.redirect("/login");
            return session;
        }

        if (user == cast(const User) User.init)
        {
            endSession(req, res);
            res.redirect("/login");
            return session;
        }

        return session;
    }
}
