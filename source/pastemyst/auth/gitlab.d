module pastemyst.auth.gitlab;

import vibe.d;
import pastemyst.data;

/++
 + gets the gitlab user from an access token
 +/
public ServiceUser getGitlabUser(string accessToken) @safe
{
    import std.conv : to;

    ServiceUser u;

    requestHTTP("https://gitlab.com/api/v4/user",
    (scope req)
    {
        req.headers.addField("Authorization", "Bearer " ~ accessToken);
    },
    (scope res)
    {
        Json j = parseJsonString(res.bodyReader.readAllUTF8());

        u.id = j["id"].get!int().to!string();
        u.username = j["username"].get!string();
        u.avatarUrl = j["avatar_url"].get!string();
    });

    return u;
}
