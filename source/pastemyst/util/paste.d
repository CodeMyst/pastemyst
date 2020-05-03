module pastemyst.util.paste;

/++
 + deletes expired pastes
 +/
public void deleteExpiredPastes()
{
    import pastemyst.time : expiresInToUnixTime;
    import pastemyst.db : find, removeOneById;
    import pastemyst.data : Paste;
    import std.datetime : Clock;

    auto pastes = find!Paste(["expiresIn": ["$ne": "never"]]);

    foreach (paste; pastes)
    {
        const expiresTime = expiresInToUnixTime(paste.createdAt, paste.expiresIn);

        if (Clock.currTime.toUnixTime() > expiresTime)
        {
            removeOneById!Paste(paste.id);
        }
    }
}