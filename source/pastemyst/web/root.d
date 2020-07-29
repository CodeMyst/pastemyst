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

    /++
     + GET /id={id}
     +
     + home page with the specified paste auto filled in (clone)
     +/
    @queryParam("id", "id")
    @path("/")
    public void getHome(string id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        UserSession session = UserSession.init;
        User user = User.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
            user = findOneById!User(session.user.id);
        }

        const pasteRes = findOneById!Paste(id);

        if (pasteRes.isNull)
        {
            return;
        }

        const paste = pasteRes.get();

        if (paste.isPrivate && (paste.ownerId != session.user.id))
        {
            return;
        }

        render!("home.dt", session, user, paste);
    }
}
