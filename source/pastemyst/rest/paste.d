module pastemyst.rest.paste;

import pastemyst.data;
import vibe.d;

version(unittest)
{
    import dshould;
}

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
        import pastemyst.encoding : randomBase36Id;
        import pastemyst.conv : valueToEnum;
        import std.typecons : Nullable;
        import std.datetime : Clock;
        import pastemyst.db : insert, findOneById;
        import pastemyst.data.paste : Paste;
        import pastemyst.data.file : languages;
        import std.uni : toLower;

        enforceHTTP(!pasties.length == 0, HTTPStatus.badRequest, "Pasties arrays has to have at least one element.");

        Nullable!ExpiresIn expires = valueToEnum!ExpiresIn(expiresIn);

        enforceHTTP(!expires.isNull, HTTPStatus.badRequest, "Invalid expiresIn value.");

        foreach (pasty; pasties)
        {
            bool languageFound = false;
            foreach (language; languages.byValue ())
            {
                if (language["name"].get!string().toLower() == pasty.language.toLower())
                {
                    languageFound = true;
                    break;
                }
            }

            enforceHTTP(languageFound, HTTPStatus.badRequest, "Invalid language value.");
        }

        string id = randomBase36Id();
        auto pasteResult = findOneById!Paste(id);
        while (!pasteResult.isNull)
        {
            id = randomBase36Id();
            pasteResult = findOneById!Paste(id);
        }

        Paste paste =
        {
            id: id,
            createdAt: Clock.currTime().toUnixTime(),
            expiresIn: expires.get(),
            title: title,
            // todo: do user stuff and authentication stuff
            ownerId: "",
            isPrivate: isPrivate,
            pasties: pasties
        };

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
