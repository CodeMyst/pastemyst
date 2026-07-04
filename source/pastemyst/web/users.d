module pastemyst.web.users;

import vibe.d;
import pastemyst.data;
import pastemyst.auth;

/++
 + web interface for the /users endpoint
 +/
@path("/users")
public class UsersWeb
{
    @path("/:username")
    public void getUser(HTTPServerRequest req, string _username, string search = "")
    {
        import pastemyst.db : findOne, find, findOneById;
        import std.algorithm : canFind;
        import std.array : replace;
        import std.uni : toLower;

        // case-insensitive exact match on the username, anchored so it can't
        // match a substring. `.` is escaped since it's a regex metacharacter
        // (usernames only allow alphanumerics and `-_.`).
        const usernameRegex = "^" ~ _username.replace(".", "\\.") ~ "$";

        auto userTemp = findOne!User([
            "username": Bson([
                "$regex": Bson(usernameRegex),
                "$options": Bson("i")
            ])
        ]);

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

        const session = getSession(req);

        const title = user.username ~ " - public profile";

        auto res = find!BasePaste(
            [
                "ownerId": Bson(user.id),
                "isPublic": Bson(true),
            ]);

        BasePaste[] pastes;
        foreach (paste; res)
        {
            string pasteTitle;

            if (paste.encrypted)
            {
                pasteTitle = "(encrypted)";
            }
            else
            {
                pasteTitle = findOneById!Paste(paste.id).get().title;
            }

            if (search == "" || pasteTitle.toLower().canFind(search.toLower()))
            {
                pastes ~= paste;
            }
        }

        render!("publicProfile.dt", session, title, user, search, pastes);
    }
}
