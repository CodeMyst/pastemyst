module pastemyst.auth.bearer;

/++
 + Checks if the bearer token's format is valid
 +/
public bool isBearerFormatValid (string token) @safe
{
    if (token.length <= "Bearer ".length)
    {
        return false;
    }

    if (token [0.."Bearer ".length] != "Bearer ")
    {
        return false;
    }

    if (token ["Bearer ".length..$].length == 0)
    {
        return false;
    }

    return true;
}
