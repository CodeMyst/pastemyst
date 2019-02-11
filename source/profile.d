module profile;

import vibe.http.server : HTTPServerRequest, HTTPServerResponse;

public interface IProfileInterface
{
    /++
        GET /me
    +/
    public void getMe (HTTPServerRequest req, HTTPServerResponse);

    /++
        GET /logout
    +/
    public void getLogout (HTTPServerRequest req, HTTPServerResponse);
}

class ProfileInterface : IProfileInterface
{
    /++
        GET /me
    +/
    public override void getMe (HTTPServerRequest req, HTTPServerResponse)
    {
        import vibe.web.web : render;
        import web : getWebInfo, WebInfo;
        import github : getCurrentUser, User;

        const WebInfo webInfo = getWebInfo (req);

        const User user = getCurrentUser (req);

        render!("profile.dt", webInfo, user);
    }

    /++
        GET /logout
    +/
    public override void getLogout (HTTPServerRequest, HTTPServerResponse res)
    {
        import github : logout;

        logout (res);
    }
}