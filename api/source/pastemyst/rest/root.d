module pastemyst.rest.root;

import vibe.vibe;
import pastemyst.data : DataFile;

/// API Interface for the API root
@path ("/")
public interface IAPIRoot
{
    Json getLanguages () @safe;
    Json getExpireOptions () @safe;
}

public class APIRoot : IAPIRoot
{
    private Json getDataTextFileJson (DataFile dataFile)
    {
        import pastemyst.data : getDataTextFile;
        import vibe.data.json : parseJsonString;

        return parseJsonString (getDataTextFile (dataFile));
    }

    public override Json getLanguages () @trusted
    {
        return getDataTextFileJson (DataFile.LANGUAGES);
    }

    public override Json getExpireOptions () @trusted
    {
        return getDataTextFileJson (DataFile.EXPIRE_OPTIONS);
    }
}
