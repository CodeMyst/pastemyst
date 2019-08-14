module pastemyst.data.user;

import vibe.data.serialization;

/++
 + Struct representing a user
 +/
public struct User
{
    /++
     + User's ID
     +/
    @name ("_id")
    public int id;

    /++
     + User's username
     +/
    public string username;

    /++
     + User's avatar url
     +/
    public string avatar;
}
