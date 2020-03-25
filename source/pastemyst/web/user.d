module pastemyst.web.user;

import vibe.d;
import vibe.web.auth;
import pastemyst.data;

/++
 + web interface for the /user endpoint
 +/
@path("/user")
@requiresAuth
public class UserWeb
{
    /// user session
    public SessionVar!(UserSession, "user") userSession;

    /// will get called to make sure the user is authenticated
    @noRoute
    public UserSession authenticate(scope HTTPServerRequest req, scope HTTPServerResponse res) @safe
    {
        if (!req.session || !req.session.isKeySet("user"))
        {
            res.redirect("/login");
            return UserSession.init;
        }

        return req.session.get!UserSession("user");
    }

    /++
     + GET /user/profile
     +
     + user profile page
     +/
    @path("/")
    @anyAuth
    public void getProfile()
    {
        render!("profile.dt", userSession);
    }
}
