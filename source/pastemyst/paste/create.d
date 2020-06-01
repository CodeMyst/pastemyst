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
    import pastemyst.data : Paste, doesLanguageExist;
    import pastemyst.util : generateUniqueId;
    import std.uni : toLower;
    import pastemyst.time : expiresInToUnixTime;

    enforceHTTP(!pasties.length == 0, HTTPStatus.badRequest, "pasties arrays has to have at least one element.");

    Nullable!ExpiresIn expires = valueToEnum!ExpiresIn(expiresIn);

    enforceHTTP(!expires.isNull, HTTPStatus.badRequest, "invalid expiresIn value.");

    enforceHTTP(!isPrivate || ownerId != "", HTTPStatus.forbidden, "can't create a private paste if not logged in");

    foreach (pasty; pasties)
    {
        enforceHTTP(doesLanguageExist(pasty.language), HTTPStatus.badRequest, "invalid language value.");
    }

    auto currentTime = Clock.currTime().toUnixTime();
    
    ulong deletesAt = 0;

    if (expires.get() != ExpiresIn.never)
    {
        deletesAt = expiresInToUnixTime(currentTime, expires.get());
    }

    Paste paste =
    {
        id: generateUniqueId!Paste(),
        createdAt: currentTime,
        expiresIn: expires.get(),
        deletesAt: deletesAt,
        title: title,
        ownerId: ownerId,
        isPrivate: isPrivate,
    };

    foreach (pasty; pasties)
    {
        pasty.id = generateUniquePastyId(paste);
        paste.pasties ~= pasty;
    }

    return paste;
}
