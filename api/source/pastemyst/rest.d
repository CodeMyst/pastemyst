module pastemyst.rest;

import vibe.vibe;

/// API Interface for the API root
@path ("/")
public interface IAPIRoot
{
    Json getLanguages () @safe;
}

/// Class implementing the API Interface for root
public class APIRoot : IAPIRoot
{
    public override Json getLanguages () @trusted
    {
        import pastemyst.data : getDataTextFile, DataFile;
        import vibe.data.json : parseJsonString;
    
        return parseJsonString (getDataTextFile (DataFile.LANGUAGES));
    }
}
