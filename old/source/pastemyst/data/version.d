module pastemyst.data.versioning;

private string _version;

public string getVersion()
{
    return _version;
}

static this()
{
    _version = getGitVersion();
}

private string getGitVersion()
{
    import std.process : executeShell;

    auto res = executeShell("git describe --tags");

    return res.output;
}
