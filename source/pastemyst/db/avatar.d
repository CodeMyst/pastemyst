module pastemyst.db.avatar;

private const string AVATARS_PATH = "./public/assets/avatars/";

/++
 + uploads an avatar to the assets directory
 + gives it a unique id and returns the filename with the extension
 +/
public string uploadAvatar(string tempPath, string filename)
{
    import pastemyst.encoding.base36 : randomBase36Id;
    import std.path : baseName, extension;
    import std.file : copy, remove;

    string id;

    do
    {
        id = randomBase36Id();
    } while(doesAvatarExist(id));

    copy(tempPath, AVATARS_PATH ~ id ~ extension(filename));
    remove(tempPath);

    return id ~ extension(filename);
}

private bool doesAvatarExist(string filename)
{
    import std.file : dirEntries, SpanMode;
    import std.path : stripExtension;

    foreach (string name; dirEntries(AVATARS_PATH, SpanMode.shallow))
    {
        if (filename == stripExtension(name))
        {
            return true;
        }
    }

    return false;
}
