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
    @bodyParam("isPublic", "isPublic")
    @bodyParam("tags", "tags")
    @headerParam("auth", "Authorization")
    @path("/paste")
    Json post(Pasty[] pasties, string title = "", string expiresIn = "never", bool isPrivate = false, string tags = "", bool isPublic = false, string auth = "") @safe;

    /++ 
     + GET /paste/:id
     +
     + Fetches the paste.
     +/
    @headerParam("auth", "Authorization")
    @path("/paste/:id")
    Json get(string _id, string auth = "") @safe;
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
    public Json post(Pasty[] pasties, string title = "", string expiresIn = "never", bool isPrivate = false, string tags = "", bool isPublic = false, string auth = "") @safe
    {
        import pastemyst.paste : createPaste, tagsStringToArray;
        import pastemyst.db : insert, findOne;

        string ownerId = "";

        if (auth != "")
        {
            auto apiKey = findOne!ApiKey(["key": auth]);

            if (!apiKey.isNull)
            {
                ownerId = apiKey.get().id;
            }
        }

        if (isPublic || isPrivate || tags != "")
        {
            enforceHTTP(ownerId != "", HTTPStatus.forbidden, "can't create a paste using account features without providing a valid Authorization header.");
        }

        Paste paste = createPaste(title, expiresIn, pasties, isPrivate, ownerId);

        paste.isPublic = isPublic;
        paste.isPrivate = isPrivate;
        paste.tags = tagsStringToArray(tags);

        if (ownerId != "")
        {
            if (isPrivate)
            {
                enforceHTTP(!isPublic, HTTPStatus.badRequest, "the paste can't be private and shown on the profile");
            }
        }

        insert(paste);

        return serializeToJson(paste);
    }

    /++ 
     + GET /paste/:id
     +
     + Fetches the paste.
     +/
    public Json get(string _id, string auth = "") @safe
    {
        import pastemyst.db : findOneById;

        auto res = findOneById!Paste(_id);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        const paste = res.get();

        if (paste.isPrivate)
        {
            enforceHTTP(auth != "", HTTPStatus.notFound);

            string desiredToken = findOneById!ApiKey(paste.ownerId).get().key;

            enforceHTTP(auth == desiredToken, HTTPStatus.notFound);
        }

        return serializeToJson(paste);
    }
}
