module pastemyst.web.users;

import vibe.d;
import pastemyst.data;

/++
 + web interface for the /users endpoint
 +/
@path("/users")
public class UsersWeb
{
    @path("/:username")
    public void getUser(HTTPServerRequest req, string _username)
    {
        import pastemyst.db : findOne;

        auto userRes = findOne!User(["username": _username]);

        if (userRes.isNull())
        {
            return;
        }

        const user = userRes.get();

        if (!user.publicProfile)
        {
            return;
        }

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
        }

        const title = user.username ~ " - public profile";

        render!("publicProfile.dt", session, title, user);
    }
}
