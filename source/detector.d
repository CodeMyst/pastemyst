module detector;

private const string tempPath = "tmp";

string detectLanguage (string code)
{
    import std.file : mkdir, exists, getcwd, remove;
    import std.stdio : writeln;
    import std.process : execute;
    import std.string : indexOf;

    if (!exists (tempPath))
        mkdir (tempPath);

    string filePath = createRandomFile (cast (void []) code);

    auto shamanProcess = execute (["shaman-tester", "-f", getcwd ~ "/" ~ filePath]);

    remove (filePath);

    if (shamanProcess.output == "")
        return "plaintext";

    return convertLanguage (shamanProcess.output [0..shamanProcess.output.indexOf (':')]);
}

/++
    Converts the language name to a name that highlight.js can use
+/
private string convertLanguage (string language)
{
    switch (language)
    {
        case "c#": return "cs";
        default: return language;
    }
}

private string createRandomFile (void [] contents)
{
    import id : createId;
    import std.file : write, exists;

    string id;
    bool duplicate;

    do
    {
        id = createId ();

        if (exists (tempPath ~ "/" ~ id)) duplicate = true;
    } while (duplicate);

    string filePath = tempPath ~ "/" ~ id;

    write (filePath, contents);

    return filePath;
}