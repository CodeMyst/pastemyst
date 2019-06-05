module pastemyst.db;

import vibe.db.mongo.mongo;
import pastemyst.data.paste;

private MongoDatabase db;

/++
 + Connects to the MongoDB
 +/
public void connectDb (string host, string dbName)
{
    db = connectMongoDB (host).getDatabase (dbName);
}

/++
 + Inserts a new paste into the db
 +/
public void insertPaste (Paste paste) @safe
{
    MongoCollection pastesCollection = db ["pastes"];

    Json data = paste.toJson ();

    pastesCollection.insert (data);
}
