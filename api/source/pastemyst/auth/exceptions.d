module pastemyst.auth.exceptions;

public class InvalidAuthorizationException : Exception
{
    public this (string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super (msg, file, line);
    }
}
