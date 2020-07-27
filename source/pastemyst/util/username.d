module pastemyst.util.username;

import std.string;

private const(string) alpha = "abcdefghijklmnopqrstuvwxyz";
private const(string) nums = "0123456789";
private const(string) symbols = "-_";
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

@("finding special characters in username")
unittest
{
    assert(usernameHasSpecialChars("he.ll!o") == true);
    assert(usernameHasSpecialChars("he.ll_o") == false);
}