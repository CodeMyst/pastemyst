module pastemyst.rest.paste;

import pastemyst.data;
import vibe.d;

/++
 + API interface for the `/api/paste` endpoint.
 +/
@path("/api")
public interface IAPIPaste
{
    /++
     + POST /paste
     +
     + Creates a paste.
     +/
    @bodyParam("title", "title")
    @bodyParam("expiresIn", "expiresIn")
    @bodyParam("isPrivate", "isPrivate")
    @bodyParam("pasties", "pasties")
    @path("/paste")
    Json post(Pasty[] pasties, string title = "", string expiresIn = "never", bool isPrivate = false) @safe;

    /++ 
     + GET /paste/:id
     +
     + Fetches the paste.
     +/
    @path("/paste/:id")
    Json get(string _id) @safe;
}

/++ 
 + API for the `/api/paste` endpoint.
 +/
public class APIPaste : IAPIPaste
{
    /++
     + POST /paste
     +
     + Creates a paste.
     +/
    public Json post(Pasty[] pasties, string title = "", string expiresIn = "never", bool isPrivate = false) @safe
    {
        import pastemyst.paste : createPaste;
        import pastemyst.db : insert;

        Paste paste = createPaste(title, expiresIn, pasties, isPrivate, "");

        insert(paste);

        return serializeToJson(paste);
    }

    /++ 
     + GET /paste/:id
     +
     + Fetches the paste.
     +/
    public Json get(string _id) @safe
    {
        import pastemyst.db : findOneById;

        auto res = findOneById!Paste(_id);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        return serializeToJson(res.get());
    }
}
