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

/++
 + returns the authorization link for the service
 +/
public string getServiceAuthLink(Service service) @safe
{
    final switch (service)
    {
        case Service.Github:
            return "https://github.com/login/oauth/authorize?client_id=" ~ config.github.id ~ "&scope=read:user";
        case Service.Gitlab:
            return "https://gitlab.com/oauth/authorize?client_id=" ~ config.gitlab.id ~
                 "&redirect_uri=" ~ config.hostname ~ "login/gitlab/callback&response_type=code&scope=read_user";
    }
}

/++
 + returns the link to get the access token of a service
 +/
public string getServiceTokenLink(Service service, string code) @safe
{
    final switch (service)
    {
        case Service.Github:
            return "https://github.com/login/oauth/access_token?client_id=" ~ config.github.id ~
                    "&client_secret=" ~ config.github.secret ~ "&code=" ~ code;
        case Service.Gitlab:
            return "https://gitlab.com/oauth/token?client_id=" ~ config.gitlab.id ~
                    "&client_secret=" ~ config.gitlab.secret ~ "&code=" ~ code ~ 
                    "&grant_type=authorization_code&redirect_uri=" ~ config.hostname ~ "login/gitlab/callback";
    }
}
