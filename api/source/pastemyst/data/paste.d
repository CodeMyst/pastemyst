module pastemyst.data.paste;

import pastemyst.data;
import vibe.data.json;
import vibe.data.bson;

/++
 +  Structure representing a single paste
 +/
public struct Paste
{
    public string _id;
    /++
     + Unix timestamp when the paste was created
     +/
    public ulong createdAt;
    public ExpiresIn expiresIn;
    /++
     + Title of the paste (optional)
     +/
    public string title;
    public string code;
    public string language;
    /++
     + Id of the owner (if applicable)
     +/
    public string ownerId;
    public bool isPrivate;
    public bool isEdited;

    /++
     + Converts the paste to JSON.
     +
     + Since the expiresIn value is an enum, the json serializer from `vibe.data.json.serializeToJson` will serialize that to an int instead to text,
     + so this function will replace the int with the string representation of the enum.
     +/
    public Json toJson () @safe
    {
        import std.conv : to;

        Json res = serializeToJson (this);

        // Using traits to get the name of the expiresIn value.
        // This way if the name of the expiresIn value changes the compiler will report that.
        res [__traits (identifier, expiresIn)] = cast (string) expiresIn;

        return res;
    }
}
