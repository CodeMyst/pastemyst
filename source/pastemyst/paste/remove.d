module pastemyst.paste.remove;

/++
 + deletes expired pastes
 +/
public void deleteExpiredPastes()
{
    import pastemyst.db : remove;
    import pastemyst.data : Paste;
    import std.datetime : Clock;
    import vibe.d : Bson;

    remove!Paste([
        "$and": [
            Bson(["expiresIn": Bson(["$ne": Bson("never")])]),
            Bson(["deletesAt": Bson(["$lt": Bson(Clock.currTime().toUnixTime())])])
        ]]);
}