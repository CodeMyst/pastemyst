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

    /++
     + whether the user's profile is public for everyone to see
     +/
    public bool publicProfile;

    /++
     + default language for creating pasties
     +/
    public string defaultLang = "Autodetect";

    /++
     + array of starred pastes
     +/
    public string[] stars;
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

/++
 + struct holding an api key of a user
 +/
public struct ApiKey
{
    ///
    @name("_id")
    public string id;

    ///
    public string key;
}
