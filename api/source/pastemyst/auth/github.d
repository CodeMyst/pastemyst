module pastemyst.auth.github;

import vibe.vibe;
import pastemyst.data.user;

/++
 + Web interface for GitHub authorization
 +/
public class AuthGitHubWeb
{
    /++
     + `GET /auth/github`
     + Redirects to the GitHub authorization page.
     +/
    @path ("/auth/github")
    public void get () @safe
    {
        import pastemyst.config : config;

        string clientId = config ["github"] ["client_id"].to!string;

        redirect ("https://github.com/login/oauth/authorize?client_id=" ~ clientId ~ "&scope=read:user");
    }

    /++
     + `GET /auth/github`
     +
     + GitHub redirects to this path with the correct code.
     +/
    @path ("/auth/githubRedirect")
    public void getRedirect (string code, HTTPServerResponse res) @trusted
    {
        import pastemyst.config : config;
        import pastemyst.db : insertAccessToken, existsAccessToken, findOneByIdMongo, insertMongo;
        import fastjwt.jwt : encodeJWTToken, JWTAlgorithm, decodeJWTToken;
        import stringbuffer : StringBuffer;
        import std.conv : to;

        string clientId = config ["github"] ["client_id"].to!string;
        string clientSecret = config ["github"] ["client_secret"].to!string;
        string jwtSecret = config ["jwt"] ["secret"].to!string;

        string accessToken;

        requestHTTP ("https://github.com/login/oauth/access_token?client_id="
                    ~ clientId ~ "&client_secret=" ~ clientSecret ~ "&code=" ~ code,
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField ("Accept", "application/json");
        },
        (scope res)
        {
            accessToken = parseJsonString (res.bodyReader.readAllUTF8) ["access_token"].get!string;
        });

        User user = getGitHubUser (accessToken);

        StringBuffer sb;
        encodeJWTToken (sb, JWTAlgorithm.HS512, jwtSecret, "sub", user.id, "name", user.username);

        string jwtToken = sb.getData ();

        if (existsAccessToken (jwtToken))
        {
            throw new HTTPStatusException (HTTPStatus.Forbidden, "User is already logged in.");
        }

        if (findOneByIdMongo!User (user.id).isNull ())
        {
            insertMongo (user);
        }

        Cookie c = new Cookie ();
        c.path = "/";
        c.domain = "paste.myst";
        c.value = jwtToken;
        c.sameSite = Cookie.SameSite.strict;
        
        res.cookies ["github"] = c;

        insertAccessToken (jwtToken, accessToken);

        return redirect ("http://paste.myst/logged");
    }
}

/++
 + Authentication interface for GitHub.
 +/
public interface IAuthGitHubAPI
{
    /++
     + `GET /auth/isValidUser`
     +
     + Checks if the user is valid by checking the JWT and if the user's access token is known.
     +/ 
    @path ("/auth/isValidUser")
    @headerParam ("authorization", "Authorization")
    Json getIsValidUser (string authorization) @safe;
}

/++
 + Authentication interface for GitHub.
 +/
public class AuthGitHubAPI : IAuthGitHubAPI
{
    /++
     + `GET /auth/isValidUser`
     +
     + Checks if the user is valid by checking the JWT and if the user's access token is known.
     +/ 
    public Json getIsValidUser (string authorization) @trusted
    {
        import fastjwt.jwt : decodeJWTToken, JWTAlgorithm;
        import stringbuffer : StringBuffer;
        import pastemyst.config : config;
        import pastemyst.db : existsAccessToken;
        import std.conv : to;

        string jwtSecret = config ["jwt"] ["secret"].get!string;

        StringBuffer header;
        StringBuffer payload;

        string token = authorization ["Bearer ".length..$];

        const int result = decodeJWTToken (token, jwtSecret, JWTAlgorithm.HS512, header, payload);

        return Json (result == 0 && existsAccessToken (token));
    }
}

private User getGitHubUser (string accessToken) @safe
{
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
        user.username = json ["login"].get!string;
    });

    return user;
}
