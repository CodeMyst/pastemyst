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
        const user = session.getSessionUser();

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
        const user = session.getSessionUser();

        const pasteRes = findOneById!Paste(_id);

        if (pasteRes.isNull)
        {
            return;
        }

        const paste = pasteRes.get();

        if (paste.isPrivate && (paste.ownerId != session.userId))
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

    @path("/legal")
    public void getLegal(HTTPServerRequest req)
    {
        const session = getSession(req);

        const title = "legal";

        render!("legal.dt", session, title);
    }

    @path("/pastry")
    public void getPastry(HTTPServerRequest req)
    {
        const session = getSession(req);

        const title = "pastry";

        render!("pastry.dt", session, title);
    }
}
