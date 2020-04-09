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
        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
        }

		render!("home.dt", session);
    }
}
