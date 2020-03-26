module pastemyst.auth.gitlab;

import vibe.d;

///
public struct GitlabUser
{
    ///
    public int id;
    ///
    public string username;
    ///
    public string avatarUrl;
}

/++
 + gets the gitlab user from an access token
 +/
public GitlabUser getGitlabUser(string accessToken) @safe
{
    GitlabUser u;

    requestHTTP("https://gitlab.com/api/v4/user",
    (scope req)
    {
        req.headers.addField("Authorization", "Bearer " ~ accessToken);
    },
    (scope res)
    {
        Json j = parseJsonString(res.bodyReader.readAllUTF8());

        u.id = j["id"].get!int();
        u.username = j["username"].get!string();
        u.avatarUrl = j["avatar_url"].get!string();
    });

    return u;
}
