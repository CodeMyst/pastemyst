module pastemyst.data.versioning;

private string _version;

public string getVersion()
{
    return _version;
}

static this()
{
    import std.file : exists, readText;
    import std.string : strip;

    // in production the version is baked into a VERSION file at build time so we
    // don't depend on git (or a .git directory) being available at runtime.
    if (exists("VERSION"))
    {
        _version = readText("VERSION").strip();
    }
    else
    {
        _version = getGitVersion();
    }
}

private string getGitVersion()
{
    import std.process : executeShell;
    import std.string : strip;

    auto res = executeShell("git describe --tags");

    return res.output.strip();
}
