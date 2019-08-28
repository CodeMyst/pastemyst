module pastemyst.conv.to;

/++
 + Converts an enum value to an enum.
 +
 + Examples:
 + --------------------
 + enum Value : string
 + {
 +      one = "1",
 +      two = "2"
 + }
 +
 + Value value = valueToEnum!Value ("1"); // returns Value.one
 + -------------------
 +/
public T valueToEnum (T, R) (R value)
{
    T [R] lookup;

    static foreach (member; __traits (allMembers, T))
    {
        lookup [cast (R) __traits (getMember, T, member)] = __traits (getMember, T, member);
    }

    return *(value in lookup);
}

/++
 + Converts an expires in time (1h, 2h, etc.) to a unix time (when the paste expires).
 +/
public long expiresInToUnixTime (long createdAt, string expiresIn)
{
    long expiresInUnixTime = createdAt;

	switch (expiresIn)
	{
		case "1h":
			expiresInUnixTime += 3600;
			break;
		case "2h":
			expiresInUnixTime += 2 * 3600;
			break;
		case "10h":
			expiresInUnixTime += 10 * 3600;
			break;
		case "1d":
			expiresInUnixTime += 24 * 3600;
			break;
		case "2d":
			expiresInUnixTime += 48 * 3600;
			break;
		case "1w":
			expiresInUnixTime += 168 * 3600;
			break;
		case "never":
			expiresInUnixTime = 0;
			break;
		default: break;
	}

	return expiresInUnixTime;
}
