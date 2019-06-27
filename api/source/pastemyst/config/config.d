module pastemyst.config.config;

import vibe.vibe;

private const string configPath = "config.json";

/++
 + Configuration file as JSON
 +/
public static Json config;

static this ()
{
    import std.file : readText;

    config = parseJsonString (readText (configPath));
}
