module pastemyst.rest.paste;

import vibe.vibe;
import pastemyst.data;

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
    @bodyParam ("isPrivate", "isPrivate")
    @bodyParam ("title", "title")
    @bodyParam ("pasties", "pasties")
    @headerParam ("authorization", "Authorization")
    @path ("/paste")
    Json post (string title, string expiresIn, bool isPrivate, Pasty [] pasties, string authorization = "") @safe;

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
    public Json post (string title, string expiresIn, bool isPrivate, Pasty [] pasties, string authorization = "") @safe
    {
        import pastemyst.db : insertMongo;
        import pastemyst.encoding : randomBase36String;
        import pastemyst.conv : valueToEnum;
        import pastemyst.auth : getGitHubUserJwt, enforceBearerFormat, getToken;
        import std.datetime.systime : Clock;
        import std.conv : to;

        if (pasties.length == 0)
        {
            throw new HTTPStatusException (HTTPStatus.badRequest, "Pasties array has to have at least one element.");
        }

        string ownerId = "";

        if (authorization != "")
        {
            enforceBearerFormat (authorization);
            string token = getToken (authorization);

            ownerId = getGitHubUserJwt (token).id.to!string ();
        }

        Paste paste =
        {
            id: randomBase36String (),
            createdAt: Clock.currTime ().toUnixTime (),
            expiresIn: valueToEnum!ExpiresIn (expiresIn),
            title: title,
            ownerId: ownerId,
            isPrivate: isPrivate,
            pasties: pasties
        };

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
            const (Paste) p = result.get ();

            if (p.isPrivate && p.ownerId != ownerId)
            {
                throw new HTTPStatusException (HTTPStatus.notFound);
            }

            return p.toJson ();
        }
    }
}
