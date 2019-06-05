module pastemyst.encoding.base36;

private const string base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz";

/++
 +  Encodes a `long` value to a base36 string.
 +/
public string encodeBase36 (const long value) @safe
    in (value >= 0)
{
    import std.algorithm.mutation : reverse;
    import std.conv : to;

    char [] result;
    long temp = value;
    while (temp != 0)
    {
        result ~= base36Chars [temp % 36];
        temp /= 36;
    }

    return to!string (result.reverse ());
}

/++
 + Generates a random base36 string with 8 characters (used for IDs).
 +/
public string randomBase36String () @safe
{
    import std.random : uniform;

    return encodeBase36 (uniform (78_364_164_096, 2_821_109_907_455));
}
