module pastemyst.auth.services;

import vibe.d;
import pastemyst.data;

/++
 + Type of user service
 +/
public enum Service
{
    Github,
    Gitlab
}

/++
 + returns the appropriate service user from an access token
 +/
public ServiceUser getServiceUser(Service service, string accessToken) @safe
{
    import std.conv : to;

    ServiceUser user;

    string url;
    string token;
    string usernameField;

    final switch (service)
    {
        case Service.Github:
            url = "https://api.github.com/user";
            token = "token";
            usernameField = "login";
            break;
        case Service.Gitlab:
            url = "https://gitlab.com/api/v4/user";
            token = "Bearer";
            usernameField = "username";
            break;
    }

    requestHTTP(url,
        (scope req)
        {
            req.headers.addField("Authorization", token ~ " " ~ accessToken);
        },
        (scope res)
        {
            const json = parseJsonString(res.bodyReader.readAllUTF8());

            user.id = json["id"].get!int().to!string();
            user.username = json[usernameField].get!string();
            user.avatarUrl = json["avatar_url"].get!string();
        });

    return user;
}
