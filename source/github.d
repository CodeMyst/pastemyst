module github;

import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

public void authorize ()
{
    import vibe.web.web : redirect;
    import appsettings : GitHubSettings, getGitHubSettings;

    auto settings = getGitHubSettings ();

    redirect ("https://github.com/login/oauth/authorize?client_id=" ~ settings.clientId ~ "&scope=read:user%20user:email");
}

public string getAccessToken (string code)
{
    import vibe.http.client : requestHTTP;
    import vibe.http.common : HTTPMethod;
    import vibe.stream.operations : readAllUTF8;
    import vibe.data.json : parseJsonString;
    import appsettings : GitHubSettings, getGitHubSettings;

    auto settings = getGitHubSettings ();

    string accessToken;

    requestHTTP ("https://github.com/login/oauth/access_token?client_id=" ~ settings.clientId ~ "&client_secret=" ~ settings.clientSecret ~ "&code=" ~ code,
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField ("Accept", "application/json");
        },
        (scope res)
        {
            accessToken = parseJsonString (res.bodyReader.readAllUTF8) ["access_token"].get!string;
        });

    return accessToken;
}

public void logout (HTTPServerResponse res)
{
    import vibe.web.web : redirect;
    import vibe.http.common : Cookie;

    Cookie c = new Cookie;
    c.path = "/";
    c.value = "";

    res.cookies ["github"] = c;

    redirect ("/");
}

public bool isLoggedIn (HTTPServerRequest req)
{
    return req.cookies.get ("github") !is null && req.cookies.get ("github") != "";
}

public bool isRegistered (string accessToken)
{
    import db : getConnection, releaseConnection;
    import mysql : Connection, MySQLRow;
    import vibe.core.log : logInfo;

    Connection connection = getConnection ();

    User user = getCurrentUser (accessToken);

	MySQLRow countRow;
    connection.execute ("select count(*) from Users where login = ?", user.login, (MySQLRow row)
    {
        countRow = row;
    });

    connection.releaseConnection ();

    return countRow [0].get!long != 0;
}

public void register (string accessToken)
{
    import db : getConnection, releaseConnection;
    import mysql : Connection;

    User user = getCurrentUser (accessToken);

    Connection connection = getConnection ();

    connection.execute ("insert into Users (id, login, email) values (?, ?, ?)", user.id, user.login, user.email);

    connection.releaseConnection ();
}

public User getCurrentUser (string accessToken)
{
    import vibe.http.client : requestHTTP;
    import vibe.data.json : parseJsonString, Json;
    import vibe.stream.operations : readAllUTF8;

    User user;

    requestHTTP ("https://api.github.com/user",
        (scope req)
        {
            req.headers.addField ("Authorization", "token " ~ accessToken);
        },
        (scope res)
        {
            Json json = parseJsonString (res.bodyReader.readAllUTF8);

            user.id = json ["id"].get!int;
            user.login = json ["login"].get!string;
            user.email = getEmail (accessToken);
        });

    return user;
}

public User getCurrentUser (HTTPServerRequest req)
{
    return getCurrentUser (req.cookies.get ("github"));
}

private string getEmail (string accessToken)
{
    import vibe.http.client : requestHTTP;
    import vibe.data.json : parseJsonString, Json;
    import vibe.stream.operations : readAllUTF8;

    string email;

    requestHTTP ("https://api.github.com/user/emails",
        (scope req)
        {
            req.headers.addField ("Authorization", "token " ~ accessToken);
        },
        (scope res)
        {
            Json json = parseJsonString (res.bodyReader.readAllUTF8);

            foreach (e; json.byValue)
            {
                if (e ["primary"].get!bool && e ["verified"].get!bool == true)
                {
                    email = e ["email"].get!string;
                    break;
                }
            }
        });

    return email;
}

public struct User
{
    int id;
    string login;
    string email;
}