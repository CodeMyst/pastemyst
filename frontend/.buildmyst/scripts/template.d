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

    long firstTickIndex = -1;
    long secondTickIndex = -1;

    foreach (ulong i, char c; tsContent)
    {
        if (firstTickIndex == -1 && c == '`')
        {
            firstTickIndex = i;
        }
        else if (secondTickIndex == -1 && c == '`')
        {
            secondTickIndex = i;
        }
    }

    tsContent = tsContent.replace (firstTickIndex + 1, secondTickIndex, content);

    write ("src/scripts/views/" ~ tsName, tsContent);

    remove ("dist/" ~ htmlName);
}
