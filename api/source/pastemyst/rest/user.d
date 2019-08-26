module pastemyst.rest.user;

import vibe.vibe;

/++
 + API Interface for the /user endpoint
 +/
public interface IAPIUser
{
    /++
     + GET /user
     +
     + Returns the current authenticated user.
     +/
    @path ("/user")
    @headerParam ("authorization", "Authorization")
    Json getUser (string authorization) @safe;

    /++
     + GET /user/pastes
     +
     + Returns all the user's pastes.
     +/
    @path ("/user/pastes")
    @headerParam ("authorization", "Authorization")
    Json getPastes (string authorization) @safe;
}

/++
 + Class implementing the interface for the /user endpoint
 +/
public class APIUser : IAPIUser
{
    /++
     + GET /user
     +
     + Returns the current authenticated user.
     +/
    public Json getUser (string authorization) @safe
    {
        import vibe.data.json : serializeToJson;
        import pastemyst.auth : checkBearerFormat, getGitHubUserJwt, getToken;

        checkBearerFormat (authorization);
        string token = getToken (authorization);

        return getGitHubUserJwt (token).serializeToJson ();
    }

    /++
     + GET /user/pastes
     +
     + Returns all the user's pastes.
     +/
    public Json getPastes (string authorization)
    {
        import pastemyst.auth : checkBearerFormat, getGitHubUserJwt, getToken;
        import pastemyst.data : User, Paste;
        import pastemyst.db : findMongo;
        import std.conv : to;
        import vibe.data.json : serializeToJson;

        checkBearerFormat (authorization);
        string token = getToken (authorization);

        User user = getGitHubUserJwt (token);

        Paste [] res;

        foreach (Paste paste; findMongo!Paste (["ownerId": user.id.to!string ()]))
        {
            res ~= paste;
        }

        return serializeToJson (res);
    }
}
