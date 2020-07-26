module pastemyst.rest.keys;

/++
 + generates an api key
 +/
public string generateApiKey()
{
    import pastemyst.db : find;
    import pastemyst.data : User;
    import csprng.system : CSPRNG;
    import std.base64 : Base64;

    auto rng = new CSPRNG();

    ubyte[32] bytes;
    string key;

    do
    {
        bytes = cast(ubyte[]) rng.getBytes(32);
        key = Base64.encode(bytes);
    } while (!find!User(["apiKey": key]).empty);

    return key;
}
