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
    @anyAuth
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
                 "&redirect_uri=http://localhost:5000/login/gitlab/callback&response_type=code&scope=read_user+email");
    }

    @noRoute
    private User createUser(Service type, ServiceUser serviceUser)
    {
        import pastemyst.db : findOne, insert;
        import pastemyst.util : generateUniqueId;
        import std.typecons : Nullable;
        import std.conv : to;
        import std.uni : toLower;

        string serviceName = type.to!string().toLower();

        Nullable!User u = findOne!User(["serviceIds." ~ serviceName: serviceUser.id]);
        if (u.isNull())
        {
            User user;
            user.id = generateUniqueId!User();
            user.username = serviceUser.username;
            user.avatarUrl = serviceUser.avatarUrl;
            user.serviceIds[serviceName] = serviceUser.id;
            insert(user);
            return user;
        }
        else
        {
            return u.get();
        }
    }

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

        if (req.session && req.session.isKeySet("user") && req.session.get!UserSession("user").loggedIn)
        {
            // already logged in, begin the account connection process

            UserSession session = req.session.get!UserSession("user");

            string msg;
            const string confirmLink = "/login/connect/confirm/" ~ serviceName;
            const string cancelLink = "/login/connection/cancel";

            if (findOne!User(["serviceIds." ~ serviceName: ["$ne": null]]).isNull())
            {
                // there doesn't exist another account connected with that service

                msg = "are you sure you want to connect " ~ serviceName ~
                    " to your account?";
            }
            else
            {
                // there's already an account with that service

                msg = "there already exists an account wtih " ~ serviceName ~
                    " connected to it. if you continue all data from the second account will be merged into this one," ~
                    " the settings will stay the same.";
            }

            req.session.set("connection_temp", serviceUser);

            res.render!("confirm.dt", msg, confirmLink, cancelLink, session);
        }
        else
        {
            // not logged in, start a session and redirect home

            User user = createUser(service, serviceUser);
            const MinimalUser muser = MinimalUser(user.id, user.username, user.avatarUrl);
            UserSession u;
            u.loggedIn = true;
            u.user = muser;
            u.token = accessToken;
            req.session = res.startSession();
            req.session.set("user", u);

            // FIXME: issue#55
            redirect("/#reload");
        }
    }

    /++
     + GET /login/connect/confirm
     +/
    @path("/login/connect/confirm/:serviceName")
    @anyAuth
    public void getConnectConfirm(string _serviceName, HTTPServerRequest req, HTTPServerResponse res)
    {
        import pastemyst.db : findOne, findOneById, update;

        enforceHTTP(req.session.isKeySet("connection_temp"), HTTPStatus.badRequest);

        enforceHTTP(req.session, HTTPStatus.badRequest);

        UserSession session = req.session.get!UserSession("user");

        ServiceUser serviceUser = req.session.get!ServiceUser("connection_temp");

        if (findOne!User(["serviceIds." ~ _serviceName: ["$ne": null]]).isNull())
        {
            // there doesn't exist another account connected with that service

            User user = findOneById!User(session.user.id).get();

            enforceHTTP(!(_serviceName in user.serviceIds), HTTPStatus.badRequest,
                    "you already have " ~ _serviceName ~ " connected to your account.");

            update!User(["_id": session.user.id], ["$set": ["serviceIds." ~ _serviceName: serviceUser.id]]);

            const string msg = "successfully connected " ~ _serviceName ~ " to your account, " ~
                "you can now sign into this account with " ~ _serviceName ~ ".";

            req.session.remove("connection_temp");

            res.render!("success.dt", msg, session);
        }
        else
        {
            // there's already an account with that service
            // TODO: merging accounts
        }
    }

    /++
     + GET /login/connection/cancel
     +/
    @path("/login/connection/cancel")
    @anyAuth
    public void getConnectCancel(HTTPServerRequest req)
    {
        if (req.session && req.session.isKeySet("connection_temp"))
        {
            req.session.remove("connection_temp");
        }

        redirect("/");
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
        string accessToken;

        // TODO: add handling in case the request of the token fails
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
        string accessToken;

        // TODO: add handling in case the request of the token fails
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

        loginService(Service.Gitlab, accessToken, req, res);
    }
}
