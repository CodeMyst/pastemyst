module pastemyst.web.users;

import vibe.d;
import pastemyst.data;

/++
 + web interface for the /users endpoint
 +/
@path("/users")
public class UsersWeb
{
    @path("/:username")
    public void getUser(HTTPServerRequest req, string _username, string search = "")
    {
        import pastemyst.db : findOne, find;
        import std.algorithm : canFind;

        auto userRes = findOne!User(["username": _username]);

        if (userRes.isNull())
        {
            throw new HTTPStatusException(HTTPStatus.notFound, "user either not found or the profile isn't set to public.");
        }

        const user = userRes.get();

        if (!user.publicProfile)
        {
            return;
        }

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
        }

        const title = user.username ~ " - public profile";

        auto res = find!Paste(
            [
                "ownerId": Bson(user.id),
                "isPublic": Bson(true),
            ]);

        Paste[] pastes;
        foreach (paste; res)
        {
            if (search == "" || paste.title.canFind(search))
            {
                pastes ~= paste;
            }
        }

        render!("publicProfile.dt", session, title, user, search, pastes);
    }
}
