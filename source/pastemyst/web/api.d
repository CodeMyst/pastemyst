module pastemyst.web.api;

import vibe.d;
import pastemyst.data;
import pastemyst.auth;

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

        const session = getSession(req);

        const page = _page;

        if (!exists("./public/docs/" ~ page ~ ".md"))
        {
            return;
        }

        const title = "api docs - " ~ page;

        render!("apiDocs/index.dt", page, session, title);
    }
}
