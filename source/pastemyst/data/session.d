module pastemyst.data.session;

import pastemyst.data.user;

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
     + user
     +/
    public MinimalUser user;

    /++
     + github token for the user
     +/
    public string token;
}

