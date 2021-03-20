module pastemyst.data.paste;

import pastemyst.data;
import vibe.data.json;
import vibe.data.bson;
import vibe.data.serialization;

/++
 + template that paste and encrypted paste use as a mixin to achieve polymorphism.
 +/
template BasePasteTmpl()
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
     + array of all tags for this paste
     +/
    public string[] tags;

    /++
     + number of stars
     +/
    public ulong stars;

    /++
     + is the paste encrytped?
     +/
    public bool encrypted;
}

/++
 + base paste
 +/
public struct BasePaste
{
    mixin BasePasteTmpl;
}

/++
 + Struct representing a paste.
 +/
public struct Paste
{
    mixin BasePasteTmpl;

    /++
     + Title of the paste.
     +/
    public string title;

    /++
     + Pasties of the paste. A paste can have multiple pasties which are sort of like "files".
     +/
    public Pasty[] pasties;

    /++
     + array of paste edits
     +/
    public Edit[] edits;

    /++
     + converts the paste to an encrypted paste, doesn't actually do any encryption.
     +/
    public EncryptedPaste opCast(EncryptedPaste)() const
    {
        EncryptedPaste res;
        res.id = id;
        res.createdAt = createdAt;
        res.expiresIn = expiresIn;
        res.deletesAt = deletesAt;
        res.ownerId = ownerId;
        res.isPrivate = isPrivate;
        res.encrypted = true;

        return res;
    }
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
 + struct for an encrypted paste
 +/
public struct EncryptedPaste
{
    mixin BasePasteTmpl;

    /++
     + This holds the list of Pasty objects and the title serialized to json and encrypted.
     +/
    public string encryptedData;

    /++
     + The key used to encrypt the data (encrypted).
     +/
    public string encryptedKey;

    /++
     + salt
     +/
    public string salt;
}

/++
 + struct for easier serialization of paste data
 +/
public struct EncryptedPasteData
{
    ///
    public string title;

    ///
    public Pasty[] pasties;
}
