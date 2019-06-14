void main (string [] args)
{
    import std.file : rmdirRecurse, exists;

    if (exists (args [1]))
    {
        rmdirRecurse (args [1]);
    }
}
