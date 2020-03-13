module pastemyst.web.login;

import vibe.d;

/++
 + web interface for the `/login` endpoint
 +/
@path("/login")
public class LoginWeb
{
    /++
     + GET /login
     +
     + login page
     +/
    public void get()
    {
        render!("login.dt");
    }

    /++
     + GET /login/github
     +
     + login with github
     +/
    public void getGithub()
    {
        import pastemyst.data : config;

        redirect("https://github.com/login/oauth/authorize?client_id=" ~ config.github.id ~ "&scope=read:user");
    }

    /++
     + GET /login/github/callback?code=
     +
     + github oauth callback
     +/
    @path("github/callback")
    @queryParam("code", "code")
    public void getGithubCallback(string code, HTTPServerResponse res)
    {
        import pastemyst.data : config, User;
        import pastemyst.auth : getGithubUser, getUserJwt;
        import pastemyst.db : findOneById, insert, redisSet;
        import std.conv : to;

        string accessToken;

        requestHTTP("https://github.com/login/oauth/access_token?client_id=" ~ config.github.id ~
                    "&client_secret=" ~ config.github.secret ~ "&code=" ~ code,
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField("Accept", "application/json");
        },
        (scope res)
        {
            accessToken = parseJsonString(res.bodyReader.readAllUTF8())["access_token"].get!string();
        });

        User user = getGithubUser(accessToken);

        if (!findOneById!User(user.id).isNull())
        {
            insert(user);
        }

        const string jwt = getUserJwt(user);

        Cookie c = new Cookie();
        c.path = "/";
        // todo: make sure to change this if in production
        c.domain = "localhost";
        c.value = jwt;
        c.sameSite = Cookie.SameSite.strict;
        c.httpOnly = true;

        res.cookies["jwt"] = c;

        // every time the user logs in, the access token is different so we will set the new access token every time
        redisSet(jwt, accessToken);

        redirect("/");
    }
}
