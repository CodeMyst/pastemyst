module pastemyst.auth.github;

import vibe.d;
import pastemyst.data;

/++
 + gets the github user from an access token
 +/
public ServiceUser getGithubUser(string accessToken) @safe
{
    import std.conv : to;

    ServiceUser u;

    requestHTTP("https://api.github.com/user",
    (scope req)
    {
        req.headers.addField("Authorization", "token " ~ accessToken);
    },
    (scope res)
    {
        Json j = parseJsonString(res.bodyReader.readAllUTF8());

        u.id = j["id"].get!int().to!string();
        u.username = j["login"].get!string();
        u.avatarUrl = j["avatar_url"].get!string();
    });

    return u;
}
