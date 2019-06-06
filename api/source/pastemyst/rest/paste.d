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
    @path ("/paste")
    Json post (string expiresIn, string code, string language, bool isPrivate, string title = "") @safe;

    /++
     + `GET /paste/:id`
     +
     + Gets a paste by its ID
     +/
    @path ("/paste/:id")
    Json get (string _id) @safe;
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
    public Json post (string expiresIn, string code, string language, bool isPrivate, string title = "") @safe
    {
        import pastemyst.data : Paste, ExpiresIn;
        import pastemyst.db : insertPaste;
        import pastemyst.encoding : randomBase36String;
        import pastemyst.conv : valueToEnum;
        import std.datetime.systime : Clock;
        import std.conv : to;

        Paste paste = Paste (randomBase36String (),
                             Clock.currTime.toUnixTime (),
                             valueToEnum!ExpiresIn (expiresIn),
                             title,
                             code,
                             language,
                             "",
                             isPrivate,
                             false);

        insertPaste (paste);

        return paste.toJson ();
    }

    /++
     + `GET /paste/:id`
     +
     + Gets a paste by its ID
     +/
    public Json get (string _id) @safe
    {
        import std.typecons : Nullable;
        import pastemyst.data : Paste;
        import pastemyst.db : getPaste;

        const Nullable!Paste result = getPaste (_id);

        if (result.isNull)
        {
            throw new HTTPStatusException (HTTPStatus.notFound);
        }
        else
        {
            return result.get ().toJson ();
        }
    }
}
