module pastemyst.web.login;

import vibe.d;

/++
 + web interface for the `/login` endpoint
 +/
@path("/login")
public class LoginWeb
{
    /++
     + GET /login
     +
     + login page
     +/
    public void get()
    {
        render!("login.dt");
    }

    /++
     + GET /login/github
     +
     + login with github
     +/
    public void getGithub()
    {
        logInfo("github");
    }
}
