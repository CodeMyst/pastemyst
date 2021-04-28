module pastemyst.rest.v1.paste;

import pastemyst.data;
import vibe.d;

private struct V1Paste
{
    string id;
    ulong createdAt;
    string code;
    string expiresIn;
    string language;
}

/++
 + V1 API interface for the `/api/paste/` endpoint.
 +/
@path("/api")
public interface IAPIV1Paste
{
    /++
     + POST /paste
     +
     + creates a paste
     +/
    @bodyParam("code", "code")
    @bodyParam("expiresIn", "expiresIn")
    @bodyParam("language", "language")
    @path("/paste")
    Json postPaste(string code, string expiresIn, string language = "Autodetect") @safe;

    /++
     + GET /paste?id={id}
     +
     + gets a paste
     +/
    @queryParam("vid", "id")
    @path("/paste")
    Json getPaste(string vid) @safe;
}

/++
 + V1 API for the `/api/paste` endpoint.
 +/
public class APIV1Paste : IAPIV1Paste
{
    /++
     + POST /paste
     +
     + creates a paste
     +/
    Json postPaste(string code, string expiresIn, string language = "Autodetect") @safe
    {
        import pastemyst.paste : createPaste;
        import pastemyst.db : insert, findOne;
        import std.uri : encodeComponent, decodeComponent;

        Pasty pasty;
        pasty.code = decodeComponent(code);
        pasty.language = language;
        pasty.title = "";

        Pasty[] pasties;
        pasties ~= pasty;

        Paste paste = createPaste("", expiresIn, pasties, false, "");

        insert(paste);

        auto res = V1Paste();
        res.id = paste.id;
        res.createdAt = paste.createdAt;
        res.code = encodeComponent(paste.pasties[0].code);
        res.expiresIn = paste.expiresIn;
        res.language = paste.pasties[0].language;

        return serializeToJson(res);
    }

    /++
     + GET /paste?id={id}
     +
     + gets a paste
     +/
    Json getPaste(string id) @safe
    {
        import pastemyst.db : findOneById;
        import std.uri : encodeComponent;

        auto res = findOneById!Paste(id);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        const paste = res.get();

        enforceHTTP(!paste.isPrivate, HTTPStatus.notFound);

        auto pasteres = V1Paste();
        pasteres.id = paste.id;
        pasteres.createdAt = paste.createdAt;
        pasteres.code = encodeComponent(paste.pasties[0].code);
        pasteres.expiresIn = paste.expiresIn;
        pasteres.language = paste.pasties[0].language;

        return serializeToJson(pasteres);
    }
}
