module pastemyst.rest.user;

import vibe.d;
import pastemyst.data;

/++
 + api interface for the `/api/user` endpoint
 +/
@path("/api/v2/user")
public interface IAPIUser
{
    /++
     + GET /user/self
     +
     + gets the current user identified by the token
     +/
    @path("self")
    @headerParam("auth", "Authorization")
    Json getSelf(string auth) @safe;

    /++
     + GET /:username/exists
     +
     + checks if a user exists with username
     +/
    @path(":username/exists")
    Json getExists(string _username) @safe;

    /++
     + GET /user/:username
     +
     + gets a user, only if its a public one
     +/
    @path(":username")
    Json getUser(string _username) @safe;
}

/++
 + api for the `/api/user` endpoint
 +/
public class APIUser : IAPIUser
{
    /++
     + GET /:username/exists
     +
     + checks if a user exists with username
     +/
    public Json getExists(string _username) @safe
    {
        import pastemyst.db : findOne;

        const res = findOne!User(["$text": ["$search": "\""~_username~"\""]]);

        if (res.isNull)
        {
            throw new HTTPStatusException(HTTPStatus.notFound);
        }

        return Json("");
    }

    /++
     + GET /user/:username
     +
     + gets a user, only if its a public one
     +/
    Json getUser(string _username) @safe
    {
        import pastemyst.db : findOne;

        const res = findOne!User(["$text": ["$search": _username]]);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        enforceHTTP(res.get().publicProfile, HTTPStatus.notFound);

        struct MinUser
        {
            string _id;
            string username;
            string avatarUrl;
            bool publicProfile;
            string defaultLang;
            ulong supporterLength;
            bool contributor;
        }

        const user = res.get();

        return serializeToJson(MinUser(user.id, user.username,
                    user.avatarUrl, user.publicProfile, user.defaultLang, user.supporterLength, user.contributor));
    }

    /++
     + GET /user/self
     +
     + gets the current user identified by the token
     +/
    Json getSelf(string auth) @safe
    {
        import pastemyst.db : findOne, findOneById;

        auto key = findOne!ApiKey(["key": auth]);

        enforceHTTP(!key.isNull, HTTPStatus.badRequest, "invalid token.");

        string userId = key.get().id;

        auto user = findOneById!User(userId);

        enforceHTTP(!user.isNull, HTTPStatus.notFound, "user not found.");

        return serializeToJson!User(user.get());
    }
}
