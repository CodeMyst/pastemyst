module pastemyst.db.avatar;

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

    copy(tempPath, "./public/assets/avatars/" ~ id ~ extension(filename));
    remove(tempPath);

    return id ~ extension(filename);
}

private bool doesAvatarExist(string filename)
{
    import std.file : dirEntries, SpanMode;
    import std.path : stripExtension;

    foreach (string name; dirEntries("./public/assets/avatars/", SpanMode.shallow))
    {
        if (filename == stripExtension(name))
        {
            return true;
        }
    }

    return false;
}
