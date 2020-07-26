module pastemyst.web.root;

import vibe.d;
import pastemyst.data;
import pastemyst.web;

/++
 + web interface for the `/` endpoint.
 +/
public class RootWeb
{
    /++
     + GET /
     +
     + home page
     +/
    @path("/")
    public void getHome(HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        UserSession session = UserSession.init;
        User user = User.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
            user = findOneById!User(session.user.id);
        }

        render!("home.dt", session, user);
    }
}
