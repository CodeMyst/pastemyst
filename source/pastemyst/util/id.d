module pastemyst.util.id;

import pastemyst.data;

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

/++
 + generates a unique id for an edit for a paste
 +/
public string generateUniqueEditId(Paste paste) @safe
{
    import pastemyst.encoding : randomBase36Id;
    import std.algorithm : canFind;

    string id;

    do
    {
        id = randomBase36Id();
    } while(paste.edits.canFind!((e) => e.uniqueId == id));

    return id;
}
