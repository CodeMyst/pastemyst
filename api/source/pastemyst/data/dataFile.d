module pastemyst.data.dataFile; // stfu

import std.stdio : File, readln;
import std.string : strip;

private string dataPath = "data";

/// Enum that defines all available data files.
public enum DataFile
{
    LANGUAGES,
    EXPIRE_OPTIONS
}

public File getDataFile (DataFile dataFile)
{
    final switch (dataFile)
    {
        case DataFile.LANGUAGES:
        {
            return File (getDataFilePath ("languages.json"), "r");
        }
        case DataFile.EXPIRE_OPTIONS:
        {
            return File (getDataFilePath ("expireOptions.json"), "r");
        }
    }
}

/// Gets the data file as a string
public string getDataTextFile (DataFile dataFile)
{
    string result = "";

    File file = getDataFile (dataFile);

    while (!file.eof)
    {
        result ~= strip (file.readln ());
    }

    return result;
}

/// Gets the path of a file in the data directory
private string getDataFilePath (string filename)
{
    import std.file : getcwd;

    return getcwd () ~ "/" ~ dataPath ~ "/" ~ filename;
}
