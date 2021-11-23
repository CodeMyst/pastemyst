module services.db_service;

import vibe.d;
import model;
import services;

@safe:

public class MongoDBService
{
    private const ConfigService config;

    private MongoDatabase mongo;

    public this(ConfigService config)
    {
        this.config = config;

        mongo = connectMongoDB(config.mongoConnection).getDatabase(config.mongoDatabase);
    }

    public MongoCollection getCollection(T)()
    {
        return mongo[getCollectionName!T()];
    }

    private string getCollectionName(T)()
    {
        static if (is(T == Paste))
        {
            return "pastes";
        }
        else
        {
            static assert(false, "Cannot get collection name from type " ~ T.stringof);
        }
    }
}
