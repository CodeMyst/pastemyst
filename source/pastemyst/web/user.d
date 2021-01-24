module pastemyst.web.user;

import vibe.d;
import vibe.web.auth;
import pastemyst.data;
import pastemyst.web;
import pastemyst.auth;

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
    public void getProfile(HTTPServerRequest req, string search="", string tag="")
    {
        import pastemyst.db : find, findOneById;
        import std.algorithm : canFind;
        import std.container : redBlackTree;
        import std.uni : toLower;

        auto session = getSession(req);
        const user = session.getSessionUser();
        const title = user.username ~ " - profile";

        auto tags = redBlackTree!string();

        auto pastesRes = find!BasePaste(["ownerId": session.userId]);
        BasePaste[] pastes;
        foreach (paste; pastesRes)
        {
            string pasteTitle;

            if (paste.encrypted)
            {
                pasteTitle = "(encrypted)";
            }
            else
            {
                pasteTitle = findOneById!Paste(paste.id).get().title;
            }

            if ((search == "" || pasteTitle.toLower().canFind(search.toLower())) &&
                (tag == "" || paste.tags.canFind(tag.toLower()) || (tag == "untagged" && paste.tags.length == 0)))
            {
                pastes ~= paste;
            }

            tags.insert(paste.tags);
        }

        render!("profile.dt", pastes, search, session, title, tag, tags);
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

        const session = getSession(req);
        const user = session.getSessionUser();

        const title = user.username ~ " - settings";
        render!("settings.dt", user, session, title);
    }

    /++
     + page with all of users data
     +/
    @path("/data")
    @anyAuth
    public void getData(HTTPServerRequest req)
    {
        import pastemyst.db : tryFindOneById, findOneById, find;
        import std.digest : toHexString;

        auto session = getSession(req);
        const user = session.getSessionUser();

        const userData = serializeToPrettyJson(user);
        const apiData = serializeToPrettyJson(findOneById!ApiKey(user.id).get());

        auto pastesMongo = find!BasePaste(["ownerId": user.id]);
        Paste[] pastes;
        EncryptedPaste[] encpastes;

        foreach (p; pastesMongo)
        {
            auto npaste = tryFindOneById!Paste(p.id);

            if (!npaste.isNull)
            {
                pastes ~= npaste.get();
                continue;
            }

            auto encpaste = findOneById!EncryptedPaste(p.id).get();

            encpaste.encryptedData = toHexString(cast(ubyte[]) encpaste.encryptedData);
            encpaste.salt = toHexString(cast(ubyte[]) encpaste.salt);
            encpaste.encryptedKey = toHexString(cast(ubyte[]) encpaste.encryptedKey);

            encpastes ~= encpaste;
        }

        const pasteData = serializeToPrettyJson(pastes);
        const encryptedPasteData = serializeToPrettyJson(encpastes);

        const title = user.username ~ " - data";
        render!("userData.dt", user, session, title, userData, apiData, pasteData, encryptedPasteData);
    }

    /++
     + POST /user/settings/save
     +
     + save user settings
     +/
    @path("settings/save")
    @anyAuth
    public void postSettingsSave(HTTPServerRequest req, HTTPServerResponse res,
        string username, bool publicProfile, string language)
    {
        import std.conv : to;
        import pastemyst.db : uploadAvatar, update, findOneById, findOne;
        import std.path : chainPath, baseName;
        import std.array : array, split;
        import pastemyst.data : config, getLanguageName;
        import std.file : remove, exists;
        import std.algorithm : startsWith;
        import imagefmt : read_image;
        import pastemyst.util : usernameHasSpecialChars, usernameStartsWithSymbol,
            usernameEndsWithSymbol;

        auto session = getSession(req);
        auto user = session.getSessionUser();

        if ("avatar" in req.files)
        {
            auto avatar = "avatar" in req.files;

            const img = read_image(avatar.tempPath.toString());

            enforceHTTP(!img.e, HTTPStatus.badRequest, "invalid or unsupported image uploaded");

            string avatarPath = uploadAvatar(avatar.tempPath.toString(), avatar.filename.name);

            string avatarUrl = chainPath(config.hostname, "static/assets/avatars/", avatarPath).array;

            if (user.avatarUrl.startsWith(config.hostname))
            {
                // delete old avatar
                remove("./public/assets/avatars/" ~ baseName(user.avatarUrl));
            }

            update!User(["_id": session.userId], ["$set": ["avatarUrl": avatarUrl]]);
        }

        if (user.username != username)
        {
            enforceHTTP(username.length > 0, HTTPStatus.badRequest, "username cannot be empty");

            enforceHTTP(!usernameHasSpecialChars(username),
                        HTTPStatus.badRequest, "username cannot contain special characters");

            enforceHTTP(!usernameStartsWithSymbol(username),
                    HTTPStatus.badRequest, "username cannot start with a symbol");

            enforceHTTP(!usernameEndsWithSymbol(username),
                    HTTPStatus.badRequest, "username cannot end with a symbol");

            enforceHTTP(findOne!User(["$text": ["$search": username]]).isNull,
                        HTTPStatus.badRequest, "username is taken");

            update!User(["_id": session.userId], ["$set": ["username": username]]);
        }

        if (user.publicProfile != publicProfile)
        {
            update!User(["_id": session.userId], ["$set": ["publicProfile": publicProfile]]);
        }

        if (user.defaultLang != language)
        {
            string lang = language.split(",")[0];
            enforceHTTP(!(getLanguageName(lang) is null), HTTPStatus.badRequest, "invalid language");
            update!User(["_id": session.userId], ["$set": ["defaultLang": lang]]);
        }

        setSession(req, res, session);

        redirect("/user/settings");
    }

    /++
     + GET /user/delete
     +
     + confirmation prompt for deleting the users account
     +/
    @path("/delete")
    @anyAuth
    public void getDelete(HTTPServerRequest req)
    {
        const session = getSession(req);

        const string msg = "are you sure you want to completely delete your account? this action cannot be undone.";
        const string confirmLink = "/user/delete/confirm";
        const string cancelLink = "/user/settings";

        render!("confirm.dt", msg, confirmLink, cancelLink, session);
    }

    @path("/delete/confirm")
    @anyAuth
    public void getDeleteConfirm(HTTPServerRequest req)
    {
        import pastemyst.db : remove, findOneById;
        import std.algorithm : startsWith;
        import std.path : baseName;
        import file = std.file : remove;

        auto session = getSession(req);
        auto user = session.getSessionUser();

        if (user.avatarUrl.startsWith(config.hostname))
        {
            file.remove("./public/assets/avatars/" ~ baseName(user.avatarUrl));
        }

        remove!Paste(["ownerId": session.userId]);
        remove!User(["_id": session.userId]);

        terminateSession();

        redirect("/");
    }

    /++
     + regenerates the token
     +/
    @path("settings/regen")
    @anyAuth
    public void getRegen(HTTPServerRequest req)
    {
        import pastemyst.db : update;
        import pastemyst.rest : generateApiKey;

        auto session = getSession(req);

        update!ApiKey(["_id": session.userId], ["$set": ["key": generateApiKey()]]);

        redirect("/user/settings");
    }
}
