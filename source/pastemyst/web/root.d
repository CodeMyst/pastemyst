module pastemyst.web.root;

import vibe.d;
import pastemyst.data;
import pastemyst.web;
import pastemyst.auth;

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
        const session = getSession(req);
        const user = getSessionUser(session);

        render!("home.dt", session, user);
    }

    /++
     + GET /id={id}
     +
     + home page with the specified paste auto filled in (clone)
     +/
    @path("/clone/:id")
    public void getHome(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        const session = getSession(req);
        const user = getSessionUser(session);

        const pasteRes = findOneById!Paste(_id);

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

    @path("/changelog")
    public void getChangelog(HTTPServerRequest req)
    {
        const session = getSession(req);

        const title = "changelog";

        render!("changelog.dt", session, title);
    }

    @path("/donate")
    public void getDonate(HTTPServerRequest req)
    {
        const session = getSession(req);

        const title = "donate";

        render!("donate.dt", session, title);
    }
}
