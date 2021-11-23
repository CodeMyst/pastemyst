module utils.id_utils;

import std.random;

@safe:

private const string base36Chars = "0123456789abcdefghijklmnopqrstuvwxyz";

/**
 *  Encodes a `long` value to a base36 string.
 */
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

/**
 * Generates a random 8 character ID.
 */
public string randomId(ref Random urng = rndGen) @safe
{
    // The magic numbers are for the smallest and biggest 8 character ID.

    return encodeBase36(uniform(78_364_164_096, 2_821_109_907_455, urng));
}

/** 
 * Generates a random 8 character ID as long as the predicate is true.
 */
public string randomIdPred(bool delegate(string) @safe p)
{
    string id;

    do
    {
        id = randomId();
    } while (p(id));

    return id;
}
