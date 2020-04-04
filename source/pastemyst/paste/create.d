module pastemyst.paste.create;

import vibe.d;
import pastemyst.data;

/++
 + creates a paste, to be used in web and rest interfaces
 + it validates the data but doesn't insert into the db
 +/
public Paste createPaste(string title, string expiresIn, Pasty[] pasties, bool isPrivate, string ownerId) @safe
{
    import pastemyst.encoding : randomBase36Id;
    import pastemyst.conv : valueToEnum;
    import std.typecons : Nullable;
    import std.datetime : Clock;
    import pastemyst.db : insert, findOneById;
    import pastemyst.data.paste : Paste;
    import pastemyst.data.file : languages;
    import pastemyst.util : generateUniqueId;
    import std.uni : toLower;

    enforceHTTP(!pasties.length == 0, HTTPStatus.badRequest, "pasties arrays has to have at least one element.");

    Nullable!ExpiresIn expires = valueToEnum!ExpiresIn(expiresIn);

    enforceHTTP(!expires.isNull, HTTPStatus.badRequest, "invalid expiresIn value.");

    enforceHTTP(!isPrivate || ownerId != "", HTTPStatus.forbidden, "can't create a private paste if not logged in");

    foreach (pasty; pasties)
    {
        bool languageFound = false;
        foreach (language; languages.byValue ())
        {
            if (language["name"].get!string().toLower() == pasty.language.toLower())
            {
                languageFound = true;
                break;
            }
        }

        enforceHTTP(languageFound, HTTPStatus.badRequest, "invalid language value.");
    }

    Paste paste =
    {
        id: generateUniqueId!Paste(),
        createdAt: Clock.currTime().toUnixTime(),
        expiresIn: expires.get(),
        title: title,
        ownerId: ownerId,
        isPrivate: isPrivate,
        pasties: pasties
    };

    return paste;
}
