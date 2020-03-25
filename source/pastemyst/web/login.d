module pastemyst.web.login;

import vibe.d;
import pastemyst.data;

/++
 + web interface for logging in and out
 +/
public class LoginWeb
{
    /// user session
    public SessionVar!(UserSession, "user") userSession;

    /++
     + GET /login
     +
     + login page
     +/
    @path("/login")
    public void getLogin()
    {
        render!("login.dt", userSession);
    }

    /++
     + GET /logout
     +
     + logs the user out
     +/
    @path("/logout")
    public void getLogout()
    {
        userSession = UserSession.init;
        terminateSession();
        redirect("/");
    }

    /++
     + GET /login/github
     +
     + login with github
     +/
    @path("/login/github")
    public void getGithub()
    {
        redirect("https://github.com/login/oauth/authorize?client_id=" ~ config.github.id ~ "&scope=read:user");
    }

    /++
     + GET /login/gitlab
     +
     + login with gitlab
     +/
    @path("/login/gitlab")
    public void getGitlab()
    {
        redirect("https://gitlab.com/oauth/authorize?client_id=" ~ config.gitlab.id ~ "&redirect_uri=http://localhost:5000/login/gitlab/callback&response_type=code&scope=read_user+email");
    }


    /++
     + GET /login/github/callback?code=
     +
     + github oauth callback
     +/
    @path("/login/github/callback")
    @queryParam("code", "code")
    public void getGithubCallback(string code)
    {
        import pastemyst.auth : getGithubUser;
        import pastemyst.db : findOneById, insert;

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

        UserSession u = userSession;
        u.loggedIn = true;
        u.user = user;
        u.token = accessToken;
        userSession = u;

        // FIXME: issue#55
        redirect("/#reload");
    }

    /++
     + GET /login/gitlab/callback
     +
     + gitlab oauth callback
     +/
    @path("/login/gitlab/callback")
    @queryParam("code", "code")
    public void getGitlabCallback(string code)
    {
        import pastemyst.auth : getGitlabUser;
        import pastemyst.db : findOneById, insert;

        string accessToken;

        requestHTTP("https://gitlab.com/oauth/token?client_id=" ~ config.gitlab.id ~ "&client_secret=" ~ config.gitlab.secret ~ "&code=" ~ code ~ "&grant_type=authorization_code&redirect_uri=http://localhost:5000/login/gitlab/callback",
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField("Accept", "application/json");
        },
        (scope res)
        {
            accessToken = parseJsonString(res.bodyReader.readAllUTF8())["access_token"].get!string();
        });

        User user = getGitlabUser(accessToken);

        if (!findOneById!User(user.id).isNull())
        {
            insert(user);
        }

        UserSession u = userSession;
        u.loggedIn = true;
        u.user = user;
        u.token = accessToken;
        userSession = u;

        // FIXME: issue#55
        redirect("/#reload");
    }
}
