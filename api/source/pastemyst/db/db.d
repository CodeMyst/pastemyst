module pastemyst.db.db;

import vibe.db.mongo.mongo;
import vibe.db.redis.redis;
import vibe.db.redis.types;
import pastemyst.data;
import std.typecons;

private MongoDatabase mongoDb;
private RedisDatabase redisDb;

private string getCollectionName (T) () @safe
{
    static if (is (T == Paste))
    {
        return "pastes";
    }
    else static if (is (T == User))
    {
        return "users";
    }
    else
    {
        static assert (false, "Cannot get collection name from type " ~ T.stringof);
    }
}

/++
 + Connects to the MongoDB
 +/
public void connectMongoDb (string host, string dbName) @safe
{
    mongoDb = connectMongoDB (host).getDatabase (dbName);
}

/++
 + Connects to the Redis DB
 +/
public void connectRedisDb (string host) @safe
{
    redisDb = connectRedis (host).getDatabase (0);
}

/++
 + Inserts an item into the Mongo DB.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public void insertMongo (T) (T item) @safe
{
    MongoCollection collection = mongoDb [getCollectionName!T];

    Json data;

    static if (is (T == Paste))
    {
        data = item.toJson ();
    }
    else
    {
        data = serializeToJson (item);
    }

    collection.insert (data);
}

/++
 + Removes items from the Mongo DB.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public void removeMongo (T) (T item) @safe
{
    MongoCollection collection = mongoDb [getCollectionName!T];

    collection.remove (item);
}

/++
 + Gets one item from the Mongo DB.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public Nullable!R findOneMongo (R, T) (T query) @safe
{
    MongoCollection collection = mongoDb [getCollectionName!R];

    return collection.findOne!R (query);
}

/++
 + Gets one item from the Mongo DB based on its ID.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public Nullable!R findOneByIdMongo (R, T) (T id) @safe
{
    return findOneMongo!R (["_id": id]);
}

/++
 + Gets all items from the Mongo DB.
 +
 + The collection is automatically determined from the item type. It will throw an error if you try to insert an invalid type.
 +/
public MongoCursor!R findMongo (R, T) (T query) @safe
{
    MongoCollection collection = mongoDb [getCollectionName!R];

    return collection.find!R (query);
}

/++
 + Inserts the github access token in the redis db
 +/
public void insertAccessToken (string jwtToken, string githubToken) @safe
{
    redisDb.set (jwtToken, githubToken);
}

/++
 + Checks if a github access token exists with the specified JWT token as the key
 +/
public bool existsAccessToken (string jwtToken) @safe
{
    return redisDb.exists (jwtToken);
}

/++
 + Gets the github access with the specified JWT token as the key
 +/ 
public string getAccessToken (string jwtToken) @safe
{
    return redisDb.get (jwtToken);
}
