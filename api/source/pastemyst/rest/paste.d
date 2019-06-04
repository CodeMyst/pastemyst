module pastemyst.rest.paste;

import vibe.vibe;

/// API interface for the /paste endpoint
public interface IAPIPaste
{
    /// POST /paste
    ///
    /// Creates a new paste
    @bodyParam ("expiresIn", "expiresIn")
    @bodyParam ("code", "code")
    @bodyParam ("language", "language")
    @bodyParam ("isPrivate", "isPrivate")
    @path ("/paste")
    Json post (string expiresIn, string code, string language, bool isPrivate) @safe;
}

public class APIPaste : IAPIPaste
{
    /// POST /paste
    ///
    /// Creates a new paste
    public Json post (string expiresIn, string code, string language, bool isPrivate) @safe
    {
        import pastemyst.data : Paste, ExpiresIn;
        import pastemyst.db : insertPaste;
        import std.datetime.systime : Clock;
        import std.conv : to;

        Paste paste = Paste ("abc", Clock.currTime.toUnixTime (), to!ExpiresIn (expiresIn), code, language, "", isPrivate, false);

        insertPaste (paste);

        return paste.toJson ();
    }
}
