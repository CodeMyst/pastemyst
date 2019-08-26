module pastemyst.auth.bearer;

/++
 + Checks if the bearer token's format is valid
 +/
public bool isBearerFormatValid (string authorization) @safe
{
    if (authorization.length <= "Bearer ".length)
    {
        return false;
    }

    if (authorization [0.."Bearer ".length] != "Bearer ")
    {
        return false;
    }

    if (authorization ["Bearer ".length..$].length == 0)
    {
        return false;
    }

    return true;
}

/++
 + Checks if the bearer token's format is valid
 +/
public void checkBearerFormat (string authorization) @safe
{
    import vibe.http.common : HTTPStatusException, HTTPStatus;

    if (!isBearerFormatValid (authorization))
    {
        throw new HTTPStatusException (HTTPStatus.unauthorized, "Authorization token is not valid.");
    }
}

/++
 + Returns the token from the Authorization header
 +/
public string getToken (string authorization) @safe
{
    return authorization ["Bearer ".length..$];
}
