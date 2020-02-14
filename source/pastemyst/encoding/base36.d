module pastemyst.encoding.base36;

version(unittest)
{
    import dshould;
}

private const string base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz";

/++
 +  Encodes a `long` value to a base36 string.
 +/
public string encodeBase36(const long value) @safe
    in(value >= 0)
{
    import std.algorithm.mutation : reverse;
    import std.conv : to;

    char[] result;
    long temp = value;
    while (temp != 0)
    {
        result ~= base36Chars[temp % 36];
        temp /= 36;
    }

    return to!string(result.reverse());
}

@("encoding a number to base36")
unittest
{
    encodeBase36(78_364_164_096).should.equal("10000000");
    encodeBase36(2_821_109_907_455).should.equal("zzzzzzzz");
}

/++
 + Generates a random base36 string with 8 characters (used for IDs).
 +/
public string randomBase36Id() @safe
{
    import std.random : uniform;

    // The magic numbers are for the smallest and biggest 8 character ID.

    return encodeBase36(uniform(78_364_164_096, 2_821_109_907_455));
}

@("the length of a random base36 id")
unittest
{
    randomBase36Id().length.should.equal(8);
    randomBase36Id().length.should.equal(8);
    randomBase36Id().length.should.equal(8);
    randomBase36Id().length.should.equal(8);
    randomBase36Id().length.should.equal(8);
    assert(false);
}
