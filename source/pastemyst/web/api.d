module pastemyst.web.api;

import vibe.d;
import pastemyst.data;

/++
 + web interface for the /api-docs endpoint
 +/
public class ApiDocsWeb
{
    /++
     + GET /api-docs
     +
     + root page of the api docs
     +/
    @path("/api-docs")
    public void get()
    {
        redirect("/api-docs/index");
    }

    /++
     + GET /api-docs/:page
     +
     + return the docs for the specific page
     +/
    @path("/api-docs/:page")
    public void get(HTTPServerRequest req, string _page = "")
    {
        import std.file: exists;

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
        }

        const page = _page;

        if (!exists("./public/docs/" ~ page ~ ".md"))
        {
            return;
        }

        const title = "api docs";

        render!("apiDocs/index.dt", page, session, title);
    }
}
