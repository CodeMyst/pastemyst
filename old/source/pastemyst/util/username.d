module pastemyst.util.username;

import std.string;

private enum string symbols = "-_.";

/++
 + checks if the given username contains any illegal special characters/symbols
 + returns true if at least 1 is found
 +/
public bool usernameHasSpecialChars(in string username) @safe
{
    import std.algorithm : canFind, each;
    import std.ascii : isAlphaNum;
    import std.typecons : No, Yes;

    return username.each!((ref ch) => (!isAlphaNum(ch) && !canFind(symbols, ch)) ? No.each : Yes.each) == No.each;
}

@safe
@("usernameHasSpecialChars")
unittest
{
    assert(usernameHasSpecialChars("he.ll!o"));
    assert(!usernameHasSpecialChars("he.l-l_o"));
}

/++
 + checks if the given username starts with a symbol
 + returns true if it does
 +/
public bool usernameStartsWithSymbol(in string username) @safe
    in (!usernameHasSpecialChars(username))
{
    import std.ascii : isAlphaNum;

    return !isAlphaNum(username[0]);
}

/++
 + this is only @system because AssertError is @system
 +/
@system
@("usernameStartsWithSymbol contract")
unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;

    assertThrown!AssertError(usernameStartsWithSymbol("%hello"));
}

@safe
@("usernameStartsWithSymbol")
unittest
{
    import std.format : format;

    foreach (symbol; "-_.")
        assert(usernameStartsWithSymbol(format!"%shello"(symbol)));

    assert(!usernameStartsWithSymbol("0hello"));
}

/++
 + checks if the given username ends with a symbol
 + returns true if it does
 +/
public bool usernameEndsWithSymbol(in string username) @safe
    in (!usernameHasSpecialChars(username))
{
    import std.ascii : isAlphaNum;

    return !isAlphaNum(username[$ - 1]);
}

/++
 + this is only @system because AssertError is @system
 +/
@system
@("usernameEndsWithSymbol contract")
unittest
{
    import core.exception : AssertError;
    import std.exception : assertThrown;

    assertThrown!AssertError(usernameEndsWithSymbol("hello%"));
}

@safe
@("usernameEndsWithSymbol")
unittest
{
    import std.format : format;

    foreach (symbol; "-_.")
        assert(usernameEndsWithSymbol(format!"hello%s"(symbol)));

    assert(!usernameEndsWithSymbol("hello0"));
}
