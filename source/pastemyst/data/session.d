module pastemyst.data.session;

/++
 + the current user session
 +/
public struct UserSession
{
    /++
     + is the user logged in in this session
     +/
    public bool loggedIn = false;

    /++
     + user's id
     +/
    public int id;

    /++
     + user's github access token
     +/
    public string token;
}

