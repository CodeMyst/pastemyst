module pastemyst.auth.github;

import vibe.d;

import pastemyst.data : User;

public User getGithubUser(string accessToken) @safe
{
    User u;

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
    });

    return u;
}
