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
     + Gets the language information from a language name, returns 404 if language doesn't exist.
     +/
    @path("/data/language")
    @queryParam("name", "name")
    Json getLanguage(string name) @safe;

    /++
     + GET `/data/languageExt`
     +
     + Finds the language from a specified extension, returns 404 if it couldn't find one.
     +/
    @path("/data/languageExt")
    @queryParam("extension", "extension")
    Json getLanguageExt(string extension) @safe;
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

    /++
     + GET `/data/languageExt`
     +
     + Finds the language from a specified extension, returns 404 if it couldn't find one.
     +/
    @path("/data/languageExt")
    @queryParam("extension", "extension")
    Json getLanguageExt(string extension) @safe
    {
        import pastemyst.data : languages;
        import std.uni : toLower;
        import std.algorithm : canFind;

        foreach (lang; languages.byValue())
        {
            if ("ext" in lang)
            {
                if (lang["ext"].get!(Json[]).canFind(Json(extension)))
                {
                    return lang;
                }
            }
        }

        throw new HTTPStatusException(HTTPStatus.notFound, "language not found.");
    }
}
