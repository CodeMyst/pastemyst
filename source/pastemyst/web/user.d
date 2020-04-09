module pastemyst.web.user;

import vibe.d;
import vibe.web.auth;
import pastemyst.data;
import pastemyst.web;

/++
 + web interface for the /user endpoint
 +/
@path("/user")
@requiresAuth
public class UserWeb
{
    mixin Auth;

    /++
     + GET /user/profile
     +
     + user profile page
     +/
    @path("profile")
    @anyAuth
    public void getProfile(HTTPServerRequest req)
    {
        UserSession session = req.session.get!UserSession("user");    
        const title = session.user.username ~ " - profile";

        render!("profile.dt", session, title);
    }

    /++
     + GET /user/settings
     +
     + user settings page
     +/
    @path("settings")
    @anyAuth
    public void getSettings(HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        UserSession session = req.session.get!UserSession("user");    
        User user = findOneById!User(session.user.id).get();

        const title = session.user.username ~ " - settings";
        render!("settings.dt", user, session, title);
    }
}
