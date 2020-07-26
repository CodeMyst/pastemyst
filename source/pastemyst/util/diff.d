module pastemyst.util.diff;

/++
 + generates a diff string between two pasty contents
 +/
public string generateDiff(string id, string before, string after) @trusted
{
    import std.process : execute, executeShell;
    import std.file : write, mkdir, remove, exists;
    import std.algorithm : endsWith, remove;
    import std.array : replace;
    import algo = std.algorithm : remove;

    if (!exists("tmp/"))
    {
        mkdir("tmp");
    }

    write("tmp/" ~ id ~ "-before", before.replace("\r\n", "\n"));
    write("tmp/" ~ id ~ "-after", after.replace("\r\n", "\n"));

    auto diff = execute(["diff", "-u", "tmp/" ~ id ~ "-before", "tmp/" ~ id ~ "-after"]);

    remove("tmp/" ~ id ~ "-before");
    remove("tmp/" ~ id ~ "-after");

    char[] diffOutput = cast(char[]) diff.output;

    write("tmp/" ~ id ~ "-diff", diffOutput);

    return cast(string) diffOutput;
}

/++
 + generated a string from patching a diff
 +/
public string patchDiff(string id, string current, string diff) @safe
{
    import std.process : executeShell;
    import std.file : write, mkdir, remove, exists, readText;
    import std.array : replace;

    if (!exists("tmp/"))
    {
        mkdir("tmp");
    }

    write("tmp/" ~ id ~ "-current", current.replace("\r\n", "\n"));
    write("tmp/" ~ id ~ "-diff", diff.replace("\r\n", "\n"));

    executeShell("patch -R tmp/" ~ id ~ "-current < tmp/" ~ id ~ "-diff");

    string res = readText("tmp/" ~ id ~ "-current");

    remove("tmp/" ~ id ~ "-current");
    remove("tmp/" ~ id ~ "-diff");

    return res;
}
