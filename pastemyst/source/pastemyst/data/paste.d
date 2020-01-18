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
     + Pasties of the paste. A paste can have multiple pasties which are sort of like "files".
     +/
    public Pasty[] pasties;
}


/++
 + Struct for a single Pasty. A Pasty is a part of a paste and represents a single "file", contains a title, language and code.
 +/
public struct Pasty
{
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
