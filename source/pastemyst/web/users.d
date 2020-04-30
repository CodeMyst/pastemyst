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
        import pastemyst.db : getAll, find;
        import std.algorithm : canFind;
        import std.typecons : Nullable;
        import std.uni : toLower;

        auto userRes = getAll!User();

        Nullable!User userTemp;
        foreach (u; userRes)
        {
            if (u.username.toLower() == _username.toLower())
            {
                userTemp = u;
                break;
            }
        }

        if (userTemp.isNull())
        {
            throw new HTTPStatusException(HTTPStatus.notFound,
                    "user either not found or the profile isn't set to public.");
        }

        const user = userTemp.get();

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
