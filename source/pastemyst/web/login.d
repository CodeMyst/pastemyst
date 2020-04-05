module pastemyst.web.login;

import vibe.d;
import pastemyst.data;
import pastemyst.auth;
import pastemyst.web;

/++
 + web interface for logging in and out
 +/
public class LoginWeb
{
    /++
     + GET /login
     +
     + login page
     +/
    @path("/login")
    public void getLogin(HTTPServerRequest req)
    {
        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
        }

        render!("login.dt", session);
    }

    /++
     + GET /logout
     +
     + logs the user out
     +/
    @path("/logout")
    public void getLogout(HTTPServerRequest req)
    {
        // TODO: do this only if logged in
        req.session.set("user", UserSession.init);
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
        redirect("https://gitlab.com/oauth/authorize?client_id=" ~ config.gitlab.id ~
                 "&redirect_uri=http://localhost:5000/login/gitlab/callback&response_type=code&scope=read_user+email");
    }

    // TODO: cleanup
    @noRoute
    private User createUser(UserType type, int id, string username, string avatarUrl)
    {
        import pastemyst.db : findOne, insert;
        import pastemyst.util : generateUniqueId;
        import std.typecons : Nullable;

        final switch (type)
        {
            case UserType.Github:
            {
                Nullable!User u = findOne!User(["githubId": id]);
                if (u.isNull())
                {
                    User user;
                    user.id =  generateUniqueId!User();
                    user.username = username;
                    user.avatarUrl = avatarUrl;
                    user.githubId = id;
                    insert(user);
                    return user;
                }
                else
                {
                    return u.get();
                }
            } 

            case UserType.Gitlab:
            {
                Nullable!User u = findOne!User(["gitlabId": id]);
                if (u.isNull())
                {
                    User user;
                    user.id =  generateUniqueId!User();
                    user.username = username;
                    user.avatarUrl = avatarUrl;
                    user.gitlabId = id;
                    insert(user);
                    return user;
                }
                else
                {
                    return u.get();
                }
            } 
        }
    }

    /++
     + GET /login/github/callback?code=
     +
     + github oauth callback
     +/
    // TODO: cleanup
    @path("/login/github/callback")
    @queryParam("code", "code")
    public void getGithubCallback(string code, HTTPServerRequest req, HTTPServerResponse res)
    {
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

        GithubUser ghuser = getGithubUser(accessToken);

        User user = createUser(UserType.Github, ghuser.id, ghuser.username, ghuser.avatarUrl);

        UserSession u;
        u.loggedIn = true;
        u.user = user;
        u.token = accessToken;
        req.session = res.startSession();
        req.session.set("user", u);

        // FIXME: issue#55
        redirect("/#reload");
    }

    /++
     + GET /login/gitlab/callback
     +
     + gitlab oauth callback
     +/
    // TODO: cleanup
    @path("/login/gitlab/callback")
    @queryParam("code", "code")
    public void getGitlabCallback(string code, HTTPServerRequest req, HTTPServerResponse res)
    {
        import pastemyst.db : findOneById, insert;

        string accessToken;

        requestHTTP("https://gitlab.com/oauth/token?client_id=" ~ config.gitlab.id ~
                    "&client_secret=" ~ config.gitlab.secret ~ "&code=" ~ code ~ 
                    "&grant_type=authorization_code&redirect_uri=http://localhost:5000/login/gitlab/callback",
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField("Accept", "application/json");
        },
        (scope res)
        {
            accessToken = parseJsonString(res.bodyReader.readAllUTF8())["access_token"].get!string();
        });

        GitlabUser gluser = getGitlabUser(accessToken);

        User user = createUser(UserType.Gitlab, gluser.id, gluser.username, gluser.avatarUrl);

        UserSession u;
        u.loggedIn = true;
        u.user = user;
        u.token = accessToken;
        req.session = res.startSession();
        req.session.set("user", u);

        // FIXME: issue#55
        redirect("/#reload");
    }
}
