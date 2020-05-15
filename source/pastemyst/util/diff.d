module pastemyst.util.diff;

/++
 + generates a diff string between two pasty contents
 +/
public string generateDiff(string id, string before, string after)
{
    import std.process : execute;
    import std.file : write, mkdir, remove, exists;

    if (!exists("tmp/"))
    {
        mkdir("tmp");
    }

    write("tmp/" ~ id ~ "-before", before);
    write("tmp/" ~ id ~ "-after", after);

    auto diff = execute(["diff", "-u", "tmp/" ~ id ~ "-before", "tmp/" ~ id ~ "-after"]);

    remove("tmp/" ~ id ~ "-before");
    remove("tmp/" ~ id ~ "-after");

    return diff.output;
}