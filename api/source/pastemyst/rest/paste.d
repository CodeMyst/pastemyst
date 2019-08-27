module pastemyst.rest.paste;

import vibe.vibe;

/++
 + API interface for the `/paste` endpoint.
 +/
public interface IAPIPaste
{
    /++
     + `POST /paste`
     +
     + Creates a new paste
     +/
    @bodyParam ("expiresIn", "expiresIn")
    @bodyParam ("title", "title")
    @bodyParam ("code", "code")
    @bodyParam ("language", "language")
    @bodyParam ("isPrivate", "isPrivate")
    @headerParam ("authorization", "Authorization")
    @path ("/paste")
    Json post (string expiresIn, string code, string language, bool isPrivate, string title = "", string authorization = "") @safe;

    /++
     + `GET /paste/:id`
     +
     + Gets a paste by its ID
     +/
    @path ("/paste/:id")
    @headerParam ("authorization", "Authorization")
    Json get (string _id, string authorization = "") @safe;
}

/++
 + Class implementing the interface for the `/paste` endpoint.
 +/
public class APIPaste : IAPIPaste
{
    /++
     + `POST /paste`
     +
     + Creates a new paste
     +/
    public Json post (string expiresIn, string code, string language, bool isPrivate, string title = "", string authorization = "") @safe
    {
        import pastemyst.data : Paste, ExpiresIn;
        import pastemyst.db : insertMongo;
        import pastemyst.encoding : randomBase36String;
        import pastemyst.conv : valueToEnum;
        import pastemyst.auth : getGitHubUserJwt, enforceBearerFormat, getToken;
        import std.datetime.systime : Clock;
        import std.conv : to;

        string ownerId = "";

        if (authorization != "")
        {
            enforceBearerFormat (authorization);
            string token = getToken (authorization);

            ownerId = getGitHubUserJwt (token).id.to!string ();
        }

        Paste paste = Paste (randomBase36String (),
                             Clock.currTime.toUnixTime (),
                             valueToEnum!ExpiresIn (expiresIn),
                             title,
                             code,
                             language,
                             ownerId,
                             isPrivate,
                             false);

        insertMongo (paste);

        return paste.toJson ();
    }

    /++
     + `GET /paste/:id`
     +
     + Gets a paste by its ID
     +/
    public Json get (string _id, string authorization = "") @safe
    {
        import std.typecons : Nullable;
        import pastemyst.data : Paste;
        import pastemyst.db : findOneByIdMongo;
        import pastemyst.auth : getGitHubUserJwt, enforceBearerFormat, getToken;

        string ownerId = "";

        if (authorization != "")
        {
            enforceBearerFormat (authorization);
            string token = getToken (authorization);

            ownerId = getGitHubUserJwt (token).id.to!string ();
        }

        const Nullable!Paste result = findOneByIdMongo!Paste (_id);

        if (result.isNull)
        {
            throw new HTTPStatusException (HTTPStatus.notFound);
        }
        else
        {
            Paste p = result.get ();

            if (p.isPrivate && p.ownerId != ownerId)
            {
                throw new HTTPStatusException (HTTPStatus.notFound);
            }

            return p.toJson ();
        }
    }
}
