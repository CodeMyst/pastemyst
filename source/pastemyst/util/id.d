module pastemyst.util.id;

/++
 + generates a random not taken id for a specified collection
 +/
public string generateUniqueId(T)()
{
    import pastemyst.db : findOneById;
    import pastemyst.encoding : randomBase36Id;
    import std.typecons : Nullable;

    string id;
    Nullable!T res;

    do
    {
       id = randomBase36Id();
       res = findOneById!T(id);
    } while (!res.isNull());

    return id;
}
