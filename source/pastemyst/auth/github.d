module pastemyst.auth.github;

import vibe.d;

///
public struct GithubUser
{
    ///
    public int id;
    ///
    public string username;
    ///
    public string avatarUrl;
}

/++
 + gets the github user from an access token
 +/
public GithubUser getGithubUser(string accessToken) @safe
{
    GithubUser u;

    requestHTTP("https://api.github.com/user",
    (scope req)
    {
        req.headers.addField("Authorization", "token " ~ accessToken);
    },
    (scope res)
    {
        Json j = parseJsonString(res.bodyReader.readAllUTF8());

        u.id = j["id"].get!int();
        u.username = j["login"].get!string();
        u.avatarUrl = j["avatar_url"].get!string();
    });

    return u;
}
