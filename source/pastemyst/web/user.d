module pastemyst.web.user;

import vibe.d;
import vibe.web.auth;
import pastemyst.data;
import pastemyst.web;

/++
 + web interface for the /user endpoint
 +/
@path("/user")
@requiresAuth
public class UserWeb
{
    mixin Auth;

    /++
     + GET /user/profile
     +
     + user profile page
     +/
    @path("profile")
    @anyAuth
    public void getProfile(HTTPServerRequest req)
    {
        UserSession session = req.session.get!UserSession("user");    
        const title = session.user.username ~ " - profile";

        render!("profile.dt", session, title);
    }

    /++
     + GET /user/settings
     +
     + user settings page
     +/
    @path("settings")
    @anyAuth
    public void getSettings(HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        UserSession session = req.session.get!UserSession("user");    
        User user = findOneById!User(session.user.id).get();

        const title = session.user.username ~ " - settings";
        render!("settings.dt", user, session, title);
    }

    /++
     + POST /user/settings/save
     +
     + save user settings
     +/
    @path("settings/save")
    @anyAuth
    public void postSettingsSave(HTTPServerRequest req, string username)
    {
        import std.conv : to;
        import pastemyst.db : uploadAvatar, update, findOneById;
        import std.path : chainPath, baseName;
        import std.array : array;
        import pastemyst.data : config;
        import std.file : remove;
        import std.algorithm : startsWith;

        UserSession session = req.session.get!UserSession("user");

        if ("avatar" in req.files)
        {
            auto avatar = "avatar" in req.files;

            string avatarPath = uploadAvatar(avatar.tempPath.toString(), avatar.filename.name);

            string avatarUrl = chainPath(config.hostname, "assets/avatars/", avatarPath).array;

            User user = findOneById!User(session.user.id).get();

            if (user.avatarUrl.startsWith(config.hostname))
            {
                // delete old avatar
                remove("./public/assets/avatars/" ~ baseName(user.avatarUrl));
            }

            update!User(["_id": session.user.id], ["$set": ["avatarUrl": avatarUrl]]);

            session.user.avatarUrl = avatarUrl;
        }

        if (session.user.username != username)
        {
            session.user.username = username;
            update!User(["_id": session.user.id], ["$set": ["username": username]]);
        }

        req.session.set("user", session);

        redirect("/");
    }
}
