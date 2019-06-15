void main (string [] args)
{
    import std.file : readText, write, remove;
    import std.path : stripExtension;
    import std.array : replace;
    import std.string : indexOf, lastIndexOf;

    string pugName = args [1];
    string htmlName = pugName.stripExtension () ~ ".html";
    string tsName = args [2];

    string content = readText ("dist/" ~ htmlName);

    string tsContent = readText ("src/scripts/views/" ~ tsName);

    tsContent = tsContent.replace (tsContent.indexOf ("`") + 1, tsContent.lastIndexOf ("`"), content);

    write ("src/scripts/views/" ~ tsName, tsContent);

    remove ("dist/" ~ htmlName);
}
