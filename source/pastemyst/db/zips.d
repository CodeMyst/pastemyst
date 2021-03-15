module pastemyst.db.zips;

import pastemyst.data;
import std.datetime;

private SysTime[string] zips;

/++
 + deletes all expires zip archives from disk, zips expire after 5 minutes
 +/
public void deleteZips()
{
    import std.file : remove;

    const time = Clock.currTime();
    foreach (key, val; zips)
    {
        if (time > val)
        {
            remove(key);
            zips.remove(key);
        }
    }
}

/++
 + creates a zip archive from a paste and saves it to disk
 +/
public string createZip(const Paste p)
{
    import archive.zip : ZipArchive;
    import pastemyst.data : languages;
    import std.uni : toLower;
    import pastemyst.encoding : randomBase36Id;
    import std.file : write;

    auto output = new ZipArchive();

    foreach (pasty; p.pasties)
    {
        string ext = "";
        foreach (lang; languages.byValue())
        {
            if (lang["name"].get!string().toLower() == pasty.language.toLower())
            {
                if ("ext" in lang)
                {
                    ext = lang["ext"][0].get!string();
                }
            }
        }

        auto file = new ZipArchive.File();
        file.path = pasty.id~"."~ext;
        file.data = pasty.code;
        output.addFile(file);
    }

    string path = "public/zips/pastemyst-"~p.id~"-"~randomBase36Id()~".zip";

    write(path, output.serialize());

    auto time = Clock.currTime();

    time += 5.minutes;

    zips[path] = time;

    return path;
}
