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
     + user ids for different services like github and gitlab
     +/
    public string[string] serviceIds;
}

/++
 + a user struct with minimal information, used for session storage
 +/
public struct MinimalUser
{
    ///
    public string id;

    ///
    public string username;

    ///
    public string avatarUrl;
}

/++
 + struct representing a service user (github, gitlab)
 +/
 alias ServiceUser = MinimalUser;
