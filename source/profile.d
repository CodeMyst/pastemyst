module profile;

import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import pastemyst : PasteMystInfo;

private PasteMystInfo [] getCurrentUserPastes (HTTPServerRequest req)
{
    import github : getCurrentUser;
    import db : getConnection, releaseConnection;
    import mysql : Connection, MySQLRow;

    int id = getCurrentUser (req).id;

    Connection connection = getConnection ();

    PasteMystInfo [] res;
    connection.execute ("select * from PasteMysts where ownerId = ? order by createdAt desc;", id, (MySQLRow row)
    {
        res ~= row.toStruct!PasteMystInfo;
    });

    connection.releaseConnection ();

    return res;
}

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

public class ProfileInterface : IProfileInterface
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

        PasteMystInfo [] pastes = getCurrentUserPastes (req);

        render!("profile.dt", webInfo, user, pastes);
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