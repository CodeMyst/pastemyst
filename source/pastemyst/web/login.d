module pastemyst.web.login;

import vibe.d;
import vibe.web.auth;
import pastemyst.data;
import pastemyst.auth;
import pastemyst.web;

/++
 + web interface for logging in and out
 +/
@requiresAuth
public class LoginWeb
{
    mixin Auth;

    /++
     + GET /login
     +
     + login page
     +/
    @path("/login")
    @noAuth
    public void getLogin(HTTPServerRequest req)
    {
        const session = getSession(req);

        render!("login.dt", session);
    }

    /++
     + GET /logout
     +
     + logs the user out
     +/
    @path("/logout")
    @anyAuth
    public void getLogout(HTTPServerRequest req, HTTPServerResponse res)
    {
        endSession(req, res);
        redirect("/");
    }

    /++
     + GET /login/github
     +
     + login with github
     +/
    @path("/login/github")
    @noAuth
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
    @noAuth
    public void getGitlab()
    {
        redirect("https://gitlab.com/oauth/authorize?client_id=" ~ config.gitlab.id ~
                 "&redirect_uri=" ~ config.hostname ~ "login/gitlab/callback&response_type=code&scope=read_user");
    }

    /++
     + GET /login/github/callback?code=
     +
     + github oauth callback
     +/
    @path("/login/github/callback")
    @queryParam("code", "code")
    @noAuth
    public void getGithubCallback(string code, HTTPServerRequest req, HTTPServerResponse res)
    {
        string accessToken = "";

        requestHTTP("https://github.com/login/oauth/access_token?client_id=" ~ config.github.id ~
                    "&client_secret=" ~ config.github.secret ~ "&code=" ~ code,
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField("Accept", "application/json");
        },
        (scope res)
        {
            try
            {
                accessToken = parseJsonString(res.bodyReader.readAllUTF8())["access_token"].get!string();
            }
            catch (Exception e)
            {
                throw new HTTPStatusException(HTTPStatus.badRequest,
                    "invalid request. you probably refreshed the page while creating the account.");
            }
        });

        enforceHTTP(accessToken != "", HTTPStatus.internalServerError, "failed getting the access token from github");

        loginService(Service.Github, accessToken, req, res);
    }

    /++
     + GET /login/gitlab/callback
     +
     + gitlab oauth callback
     +/
    @path("/login/gitlab/callback")
    @queryParam("code", "code")
    @noAuth
    public void getGitlabCallback(string code, HTTPServerRequest req, HTTPServerResponse res)
    {
        string accessToken = "";

        requestHTTP("https://gitlab.com/oauth/token?client_id=" ~ config.gitlab.id ~
                    "&client_secret=" ~ config.gitlab.secret ~ "&code=" ~ code ~ 
                    "&grant_type=authorization_code&redirect_uri=" ~ config.hostname ~ "login/gitlab/callback",
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField("Accept", "application/json");
        },
        (scope res)
        {
            accessToken = parseJsonString(res.bodyReader.readAllUTF8())["access_token"].get!string();
        });

        enforceHTTP(accessToken != "", HTTPStatus.internalServerError, "failed getting the access token from gitlab");

        loginService(Service.Gitlab, accessToken, req, res);
    }

    /++
     + login with a server
     +/
    @noRoute
    @noAuth
    private void loginService(Service service, string accessToken,
            HTTPServerRequest req, HTTPServerResponse res)
    {
        import std.uni : toLower;
        import std.conv : to;
        import pastemyst.db : update, findOneById, findOne;

        string serviceName = service.to!string().toLower();

        ServiceUser serviceUser;

        final switch(service)
        {
            case Service.Github:
                serviceUser = getGithubUser(accessToken);
                break;
            case Service.Gitlab:
                serviceUser = getGitlabUser(accessToken);
                break;
        }

        const user = findOne!User(["serviceIds." ~ serviceName: serviceUser.id]);

        if (user.isNull)
        {
            req.session = res.startSession();
            req.session.set("create_temp_type", serviceName);
            req.session.set("create_temp_user", serviceUser);
            const serviceUsername = serviceUser.username;
            const session = pastemyst.auth.session.Session.init;
            res.render!("createUser.dt", serviceUsername, session);
            return;
        }

        const muser = MinimalUser(user.get().id, user.get().username, user.get().avatarUrl);
        pastemyst.auth.session.Session session;
        session.user = muser;
        startSession(req, res, session);

        // FIXME: issue#55
        redirect("/#reload");
    }

    /++
     + GET /login/create
     +
     + page for creating the account
     +/
    @path("/login/create")
    @noAuth
    public void postLoginCreate(string username, HTTPServerRequest req, HTTPServerResponse res)
    {
        import pastemyst.util : generateUniqueId, usernameHasSpecialChars, usernameStartsWithSymbol,
                                usernameEndsWithSymbol;
        import pastemyst.db : findOne, insert;
        import pastemyst.rest : generateApiKey;

        enforceHTTP(req.session &&
                    req.session.isKeySet("create_temp_type") &&
                    req.session.isKeySet("create_temp_user"),
                    HTTPStatus.badRequest, "invalid request, can't create user");

        enforceHTTP(username.length > 0, HTTPStatus.badRequest, "username cannot be empty");

        enforceHTTP(!usernameHasSpecialChars(username),
                    HTTPStatus.badRequest, "username cannot contain special characters");

        enforceHTTP(!usernameStartsWithSymbol(username),
                    HTTPStatus.badRequest, "username cannot start with a symbol");

        enforceHTTP(!usernameEndsWithSymbol(username),
                    HTTPStatus.badRequest, "username cannot end with a symbol");

        const serviceName = req.session.get!string("create_temp_type");
        const serviceUser = req.session.get!ServiceUser("create_temp_user");

        const userCheck = findOne!User(["$text": ["$search": username]]);

        if (!userCheck.isNull)
        {
            terminateSession();
            endSession(req, res);
            throw new HTTPStatusException(HTTPStatus.badRequest, "username is already taken");
        }

        User user;
        user.id = generateUniqueId!User();
        user.username = username;
        user.avatarUrl = serviceUser.avatarUrl;
        user.serviceIds[serviceName] = serviceUser.id;
        insert(user);

        auto key = ApiKey(user.id, generateApiKey());

        insert(key);

        pastemyst.auth.session.Session session;
        session.user = MinimalUser(user.id, user.username, user.avatarUrl);
        
        req.session.remove("create_temp_type");
        req.session.remove("create_temp_user");

        terminateSession();

        startSession(req, res, session);

        redirect("/");
    }
}
