module pastemyst.rest.user;

import vibe.d;

/++
 + api interface for the `/api/user` endpoint
 +/
@path("/api/user")
public interface IAPIUser
{
    /++
     + GET /user/exists
     +
     + checks if a user exists with username
     +/
    @path(":username/exists")
    Json getExists(string _username) @safe;
}

/++
 + api for the `/api/user` endpoint
 +/
public class APIUser : IAPIUser
{
    /++
     + GET /user/exists
     +
     + checks if a user exists with username
     +/
    public Json getExists(string _username) @safe
    {
        import pastemyst.data : User;
        import pastemyst.db : findOne;

        const res = findOne!User(["$text": ["$search": _username]]);

        if (res.isNull)
        {
            throw new HTTPStatusException(HTTPStatus.notFound);
        }

        return Json("");
    }
}
