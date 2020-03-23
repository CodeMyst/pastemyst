module pastemyst.web.root;

import vibe.d;
import pastemyst.data;

/++
 + web interface for the `/` endpoint.
 +/
public class RootWeb
{
    /// user session
    public SessionVar!(UserSession, "user") userSession;

    /++
     + GET /
     +
     + home page
     +/
    @path("/")
    public void getHome()
    {
		render!("home.dt", userSession);
    }
}
