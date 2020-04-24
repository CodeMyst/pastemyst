module pastemyst.db.db;

import vibe.d;
import std.typecons;

version(unittest)
{
    import dshould;
}

/++
 + List of all collections in the mongo db.
 +/
public const string[] collectionNames = ["pastes", "users"];

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
    import pastemyst.data : Paste, User;

    static if (is(T == Paste))
    {
        return "pastes";
    }
    else static if (is(T == User))
    {
	    return "users";
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
    MongoCollection collection = mongo[getCollectionName!T()];

    Json data;

    data = serializeToJson(item);

    collection.insert(data);
}

/++
 + updates an item in the db
 +/
public void update(T, S, U)(S selector, U update)
{
    MongoCollection collection = mongo[getCollectionName!T()];

    collection.update(selector, update);
}

/++
 + Get the count of objects in the collection
 +/
public ulong getCollectionCount(T)()
{
    MongoCollection collection = mongo[getCollectionName!T()];

    return collection.find().count();
}

/++
 + finds all elements in the specified collection that match the query
 +/
public MongoCursor!R find(R, T)(T query) @safe
{
    MongoCollection collection = mongo[getCollectionName!R()];

    return collection.find!R(query);
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

/++
 + Removes one item from the DB, using the specified query
 +/
public void removeOne(R, T)(T query) @safe
{
    MongoCollection collection = mongo[getCollectionName!R()];
    collection.remove(query);
}

/++
 + Removes an existing object, with the specified id
 +/
public void removeOneById(R, T)(T id) @safe
{
    removeOne!R(["_id": id]);
}

version(unittest)
{
    /++
     + DANGEROUS! Drops all collections in the mongo db. Used for cleaning the db before running tests.
     +/
    public void dropAllCollections()
    {
        foreach (string c; collectionNames)
        {
            mongo[c].drop();
        }
    }
}
