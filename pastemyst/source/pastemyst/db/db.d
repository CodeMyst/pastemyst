module pastemyst.db.db;

import vibe.d;
import std.typecons;

version(unittest)
{
    import dshould;
}

private MongoDatabase mongo;

/++ 
 + Connects to the databases.
 +/
public void connect()
{
    version(unittest)
    {
        import pastemyst.data : Paste;

        connectMongo("127.0.0.1", "pastemyst-test");
    }
    else
    {
        connectMongo("127.0.0.1", "pastemyst");
    }
}

/++
 + Gets the proper collection name to use from a type.
 +/
private string getCollectionName(T)() @safe
{
    import pastemyst.data : Paste;

    static if (is(T == Paste))
    {
        return "pastes";
    }
    else
    {
        static assert(false, "Cannot get collection name from type " ~ T.stringof);
    }
}

@("getting the collection name from a struct type")
unittest
{
    import pastemyst.data : Paste;

    getCollectionName!Paste().should.equal("pastes");
}

private void connectMongo(string host, string dbName)
{
    mongo = connectMongoDB(host).getDatabase(dbName);
}

/++
 + Inserts an item into the Mongo DB.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public void insert(T)(T item)
{
    import pastemyst.data : Paste;
    
    MongoCollection collection = mongo[getCollectionName!T()];

    Json data;

    data = serializeToJson(item);

    collection.insert(data);
}

/++ 
 +
 + Gets one item from the Mongo DB.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public Nullable!R findOne(R, T)(T query) @safe
{
    MongoCollection collection = mongo[getCollectionName!R()];

    return collection.findOne!R(query);
}

/++ 
 +
 + Gets one item from the Mongo DB with the specified id (_id).
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public Nullable!R findOneById(R, T)(T id) @safe
{
    return findOne!R(["_id": id]);
}
