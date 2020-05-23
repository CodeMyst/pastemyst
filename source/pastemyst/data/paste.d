module pastemyst.data.paste;

import pastemyst.data;
import vibe.data.json;
import vibe.data.bson;
import vibe.data.serialization;

/++
 + Struct representing a paste.
 +/
public struct Paste
{
    /++
     + Paste ID. Name attribute is set to _id because in MongoDB the IDs begin with _.
     +/
    @name("_id")
    public string id;

    /++
     + When the paste is created, using unix time.
     +/
    public ulong createdAt;

    /++
     + When the paste expires.
     +/
    public ExpiresIn expiresIn;

    /++
     + When the paste will get deleted, if `expiresIn` is set to never, this value is set to 0;
     +/
    public ulong deletesAt;

    /++
     + Title of the paste.
     +/
    public string title;

    /++
     + Owner of the paste. If no owner then this value should be `null`.
     +/
    public string ownerId;

    /++
     + If the paste is private.
     +/
    public bool isPrivate;

    /++
     + does the paste show up on the user's public profile?
     +/
    public bool isPublic;

    /++
     + Pasties of the paste. A paste can have multiple pasties which are sort of like "files".
     +/
    public Pasty[] pasties;

    /++
     + array of paste edits
     +/
    public Edit[] edits;
}


/++
 + Struct for a single Pasty. A Pasty is a part of a paste and represents a single "file", contains a title, language and code.
 +/
public struct Pasty
{
    /++
     + id of the pasty
     +/
    @name("_id")
    @optional
    public string id;

    /++
     + Title of the pasty.
     +/
    public string title;

    /++
     + Language of the pasty. This stores the name of the language, not the mode or MIME type.
     +/
    public string language;

    /++
     + Code of the pasty.
     +/
    public string code;
}

/++
 + generates a unique pasty id
 +/
public string generateUniquePastyId(Paste paste) @safe
{
    import pastemyst.encoding : randomBase36Id;
    import std.algorithm : canFind;

    string id;

    do
    {
        id = randomBase36Id();
    } while(paste.pasties.canFind!((p) => p.id == id));

    return id;
}