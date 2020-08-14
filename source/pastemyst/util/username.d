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

    if (count(alphanums, username[username.length - cast(uint) 1].toLower()) != 1)
        return true;

    return false;
}

/++
 + removes any duplicate subsequent symbols from the username
 +/
public string usernameRemoveDuplicateSymbols(string username)
{
    import std.algorithm : canFind;

    if (username.length < 2)
    {
        return username;
    }

    string copy;

    foreach (i, c; username)
    {
        if (i >= username.length-2)
        {
            copy ~= c;
            continue;
        }

        if (symbols.canFind(c))
        {
            if (symbols.canFind(username[i+1]))
            {
                continue;
            }
        }

        copy ~= c;
    }

    return copy;
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

    assert(usernameRemoveDuplicateSymbols("c") == "c");
    assert(usernameRemoveDuplicateSymbols("co") == "co");
    assert(usernameRemoveDuplicateSymbols("codemyst") == "codemyst");
    assert(usernameRemoveDuplicateSymbols("code__myst") == "code_myst");
    assert(usernameRemoveDuplicateSymbols("code--myst") == "code-myst");
    assert(usernameRemoveDuplicateSymbols("code__--myst") == "code-myst");
    assert(usernameRemoveDuplicateSymbols("code__--..myst") == "code.myst");
}
