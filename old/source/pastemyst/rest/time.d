module pastemyst.rest.time;

import vibe.d;

/++
 + API interface for doing time stuff. `/api/time` endpoint.
 +/
@path("/api/v2")
public interface IAPITime
{
    /++
     + GET /time/expiresInToUnixTime
     + 
     + converts the expires in value to a specific time when the paste expires according to the created at time.
     +/
    @path("/time/expiresInToUnixTime")
    @queryParam("createdAt", "createdAt")
    @queryParam("expiresIn", "expiresIn")
    Json getExpiresInToUnixTime(ulong createdAt, string expiresIn) @safe;
}

/++
 + API for doing time stuff. `/api/time` endpoint.
 +/
public class APITime : IAPITime
{
    /++
     + GET /time/expiresInToUnixTime
     + 
     + converts the expires in value to a specific time when the paste expires according to the created at time.
     +/
    public Json getExpiresInToUnixTime(ulong createdAt, string expiresIn) @safe
    {
        import pastemyst.time : expiresInToUnixTime;
        import pastemyst.data : ExpiresIn;
        import std.typecons : Nullable;
        import pastemyst.conv : valueToEnum;

        Nullable!ExpiresIn expires = valueToEnum!ExpiresIn(expiresIn);

        enforceHTTP(!expires.isNull, HTTPStatus.badRequest, "invalid expiresIn value.");

        return Json(["result": Json(expiresInToUnixTime(createdAt, expires.get()))]);
    }
}
