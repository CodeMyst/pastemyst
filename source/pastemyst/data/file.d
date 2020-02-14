module pastemyst.data.file;

import std.stdio : File, readln;
import std.string : strip;
import vibe.d;

version(unittest)
{
    import dshould;
}

/++ 
 + Expire options Json object.
 +/
@property
public Json expireOptions() { return _expireOptions; }
private Json _expireOptions;

/++ 
 + All supported languages Json object.
 +/
@property
public Json languages() { return _languages; }
private Json _languages;

@("expire options and languages json files")
unittest
{
    Json res = expireOptions;

    res[0]["value"].should.equal("never");

    Json res2 = languages;

    res2[0]["name"].should.equal("Autodetect");
}

private const string dataPath = "data";

/++
 + Enum that defines all possible data files.
 +/
public enum DataFile
{
    EXPIRE_OPTIONS,
    LANGUAGES
}

static this()
{
    _expireOptions = parseJsonString(getTextDataFile(DataFile.EXPIRE_OPTIONS))["expireOptions"];
    _languages = parseJsonString(getTextDataFile(DataFile.LANGUAGES))["languages"];
}

/++ 
 + Gets the data file. 
 + Params:
 +   dataFile = Type of data file.
 + Returns: File struct.
 +/
public File getDataFile(DataFile dataFile)
{
    final switch (dataFile)
    {
        case DataFile.EXPIRE_OPTIONS:
        {
            return File(getDataFilePath("expireOptions.json"), "r");
        }
        case DataFile.LANGUAGES:
        {
            return File(getDataFilePath("languages.json"), "r");
        }
    }
}

@("getting json data files")
unittest
{
    import std.path : baseName;

    File dtfile = getDataFile(DataFile.EXPIRE_OPTIONS);

    baseName(dtfile.name).should.equal("expireOptions.json");

    File dtfile2 = getDataFile(DataFile.LANGUAGES);

    baseName(dtfile2.name).should.equal("languages.json");
}

/++ 
 + Gets the data file as a string.
 + Params:
 +   dataFile = Type of data file.
 + Returns: String contents of the file.
 +/
public string getTextDataFile(DataFile dataFile)
{
    string res = "";

    File file = getDataFile(dataFile);

    while (!file.eof())
    {
        res ~= strip(file.readln());
    }

    return res;
}

@("expireOptions.json file correctness")
unittest
{
    const string contents = getTextDataFile(DataFile.EXPIRE_OPTIONS);

    contents.should.equal(`{"expireOptions":[{"value": "never","pretty": "never"},` ~
                          `{"value": "1h","pretty": "1 hour"},` ~
                          `{"value": "2h","pretty": "2 hours"},` ~
                          `{"value": "10h","pretty": "10 hours"},` ~
                          `{"value": "1d","pretty": "1 day"},` ~
                          `{"value": "2d","pretty": "2 days"},` ~
                          `{"value": "1w","pretty": "1 week"}]}`);
}

/++ 
 + Gets the path to the data file inside the `dataPath` folder.
 + Params:
 +   filename = Name of the file (with the extension).
 + Returns: The path to the data file.
 +/
private string getDataFilePath(string filename)
{
    import std.file : getcwd;

    return getcwd() ~ "/" ~ dataPath ~ "/" ~ filename;
}
