module pastemyst.data.user;

import vibe.data.json;
import vibe.data.bson;
import vibe.data.serialization;
import std.typecons : Nullable;

/++
 + Struct representing a user.
 +/
public struct User
{
    /++
     + User's id.
     +/
    @name("_id")
    public string id;
    
    /++
     + User's username.
     +/
    public string username;

    /++
     + User's avatar url
     +/
    public string avatarUrl;

    /++
     + github user id
     +/
    public Nullable!int githubId;

    /++
     + gitlab user id
     +/
    public Nullable!int gitlabId;
}
