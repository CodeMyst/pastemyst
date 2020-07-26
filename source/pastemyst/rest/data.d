module pastemyst.rest.data;

import vibe.d;

/++
 + API interface for getting various simple data. `/api/data` endpoint.
 +/
@path("/api/v2")
public interface IAPIData
{
    /++
     + GET `/data/language`
     +
     + Gets the language information from a language name, returns null if language doesn't exist.
     +/
    @path("/data/language")
    @queryParam("name", "name")
    Json getLanguage(string name) @safe;
}

/++
 + API for getting various simple data. `/api/data` endpoint.
 +/
public class APIData : IAPIData
{
    /++
     + GET `/data/language`
     +
     + Gets the language information from a language name, returns 404 if language doesn't exist.
     +/
    public Json getLanguage(string name) @safe
    {
        import pastemyst.data : languages;
        import std.uni : toLower;

        foreach (lang; languages.byValue())
        {
            if (lang["name"].get!string().toLower() == name.toLower())
            {
                return lang;
            }
        }

        throw new HTTPStatusException(HTTPStatus.notFound, "language not found.");
    }
}
