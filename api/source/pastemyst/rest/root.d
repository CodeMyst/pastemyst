module pastemyst.rest.root;

import vibe.vibe;
import pastemyst.data : DataFile;

/++
 + API Interface for the API root endpoint
 +/
@path ("/")
public interface IAPIRoot
{
    /++
     + `GET /languages`
     +
     + Returns the information about all possible languages.
     +/
    Json getLanguages () @safe;

    /++
     + `GET /expireOptions`
     +
     + Returns all the available "expires in" options.
     +/
    Json getExpireOptions () @safe;
}

/++
 + Class implementing the interface for the root endpoint
 +/
public class APIRoot : IAPIRoot
{
    private Json getDataTextFileJson (DataFile dataFile)
    {
        import pastemyst.data : getDataTextFile;
        import vibe.data.json : parseJsonString;

        return parseJsonString (getDataTextFile (dataFile));
    }

    /++
     + `GET /languages`
     +
     + Return the information about all possible languages.
     +/
    public override Json getLanguages () @trusted
    {
        return getDataTextFileJson (DataFile.LANGUAGES);
    }

    /++
     + `GET /expireOptions`
     +
     + Returns all the available "expires in" options.
     +/
    public override Json getExpireOptions () @trusted
    {
        return getDataTextFileJson (DataFile.EXPIRE_OPTIONS);
    }
}
