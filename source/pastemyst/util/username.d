module pastemyst.util.username;

import std.string;

private const(string) alpha = "abcdefghijklmnopqrstuvwxyz";
private const(string) nums = "0123456789";
private const(string) alphanums = alpha ~ nums;
private const(string) symbols = "-_.";
private const(string) alphanumerics = alpha ~ nums ~ symbols;

/++
 + checks if the given username contains any illegal special characters/symbols
 + returns true if at least 1 is found
 +/
public bool usernameHasSpecialChars(string username)
{
    foreach (c; username)
    {
        import std.algorithm : count;

        if (count(alphanumerics, c.toLower()) != 1)
            return true;
    }

    return false;
}

/++
 + checks if the given username starts with a symbol
 + returns true if it does
 +/
public bool usernameStartsWithSymbol(string username)
{
    import std.algorithm : count;

    if (count(alphanums, username[0].toLower()) != 1)
        return true;

    return false;
}

/++
 + checks if the given username ends with a symbol
 + returns true if it does
 +/
public bool usernameEndsWithSymbol(string username)
{
    import std.algorithm : count;

    if (count(alphanums, username[username.length - 1].toLower()) != 1)
        return true;

    return false;
}

@("finding special characters in username")
unittest
{
    assert(usernameHasSpecialChars("he.ll!o") == true);
    assert(usernameHasSpecialChars("he.ll_o") == false);

    assert(usernameStartsWithSymbol("_hello") == true);
    assert(usernameStartsWithSymbol("0hello") == false);
    assert(usernameEndsWithSymbol("hello_") == true);
    assert(usernameEndsWithSymbol("hello.") == true);
    assert(usernameEndsWithSymbol("hello9") == false);
}