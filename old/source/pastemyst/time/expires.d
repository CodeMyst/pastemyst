module pastemyst.time.expires;

import pastemyst.data.expires;

/++
 + converts the expires in value to a specific time when the paste expires according to the created at time.
 +/
public long expiresInToUnixTime(long createdAt, ExpiresIn expiresIn) @safe
{
    long expiresInUnixTime = createdAt;

	switch (expiresIn)
	{
		case ExpiresIn.oneHour:
			expiresInUnixTime += 3600;
			break;
		case ExpiresIn.twoHours:
			expiresInUnixTime += 2 * 3600;
			break;
		case ExpiresIn.tenHours:
			expiresInUnixTime += 10 * 3600;
			break;
		case ExpiresIn.oneDay:
			expiresInUnixTime += 24 * 3600;
			break;
		case ExpiresIn.twoDays:
			expiresInUnixTime += 48 * 3600;
			break;
		case ExpiresIn.oneWeek:
			expiresInUnixTime += 168 * 3600;
			break;
		case ExpiresIn.oneMonth:
			expiresInUnixTime += 2_629_800;
			break;
		case ExpiresIn.oneYear:
			expiresInUnixTime += 31_557_600;
			break;
		case ExpiresIn.never:
			expiresInUnixTime = 0;
			break;
		default: break;
	}

	return expiresInUnixTime;
}

@("converting expires in to unix time")
unittest
{
    assert(expiresInToUnixTime(1, ExpiresIn.oneHour) == 3601);
    assert(expiresInToUnixTime(58_673, ExpiresIn.twoHours) == 65_873);
    assert(expiresInToUnixTime(58_673, ExpiresIn.tenHours) == 94_673);
    assert(expiresInToUnixTime(58_673, ExpiresIn.oneDay) == 145_073);
    assert(expiresInToUnixTime(58_673, ExpiresIn.twoDays) == 231_473);
    assert(expiresInToUnixTime(58_673, ExpiresIn.oneWeek) == 663_473);
    assert(expiresInToUnixTime(58_673, ExpiresIn.oneMonth) == 2_688_473);
    assert(expiresInToUnixTime(58_673, ExpiresIn.oneYear) == 31_616_273);
    assert(expiresInToUnixTime(58_673, ExpiresIn.never) == 0);
}
