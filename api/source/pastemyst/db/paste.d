module pastemyst.db.paste;

/++
 + Deletes all expires pastes from the database.
 +/
public void deleteExpiredPastes ()
{
    import pastemyst.db : findMongo, removeMongo;
    import pastemyst.data : Paste;
    import pastemyst.conv : expiresInToUnixTime;
    import vibe.db.mongo.mongo : Bson;
    import std.datetime : Clock;

    Bson query = Bson (["expiresIn": Bson (["$ne": Bson ("never")])]);

    foreach (Paste paste; findMongo!Paste (query))
    {
        if (Clock.currTime ().toUnixTime () >= expiresInToUnixTime (paste.createdAt, paste.expiresIn))
        {
            removeMongo (paste);
        }
    }
}
