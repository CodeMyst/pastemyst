module pastemyst.util.diff;

/++
 + generates a diff string between two pasty contents
 +/
public string generateDiff(string id, string before, string after) @trusted
{
    import std.process : execute;
    import std.file : write, mkdir, remove, exists;
    import std.algorithm : endsWith, remove;
    import algo = std.algorithm : remove;

    if (!exists("tmp/"))
    {
        mkdir("tmp");
    }

    write("tmp/" ~ id ~ "-before", before);
    write("tmp/" ~ id ~ "-after", after);

    auto diff = execute(["diff", "-u", "tmp/" ~ id ~ "-before", "tmp/" ~ id ~ "-after"]);

    remove("tmp/" ~ id ~ "-before");
    remove("tmp/" ~ id ~ "-after");

    char[] diffOutput = cast(char[]) diff.output;

    if (diff.output.endsWith("\r\n"))
    {
        const ulong len = diff.output.length;
        diffOutput = algo.remove(diffOutput, len-2, len-1);
    }
    else if (diff.output.endsWith("\n"))
    {
        const ulong len = diff.output.length;
        diffOutput = algo.remove(diffOutput, len-1);
    }

    return cast(string) diffOutput;
}

/++
 + generated a string from patching a diff
 +/
public string patchDiff(string id, string current, string diff) @safe
{
    import std.process : executeShell;
    import std.file : write, mkdir, remove, exists, readText;

    if (!exists("tmp/"))
    {
        mkdir("tmp");
    }

    write("tmp/" ~ id ~ "-current", current);
    write("tmp/" ~ id ~ "-diff", diff);

    executeShell("patch -R tmp/" ~ id ~ "-current < tmp/" ~ id ~ "-diff");

    string res = readText("tmp/" ~ id ~ "-current");

    remove("tmp/" ~ id ~ "-current");
    remove("tmp/" ~ id ~ "-diff");

    return res;
}
