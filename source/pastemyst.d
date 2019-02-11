module pastemyst;

/++
    Structure that contains all info about a PasteMyst
+/
public struct PasteMystInfo
{
    /++
        ID of the PasteMyst
    +/
	public string id;
    /++
        When the PasteMyst is created, in UNIX time
    +/
	public long createdAt;
    /++
        When the PasteMyst expires. Valid values are: never, 1h, 2h, 10h, 1d, 2d or 1w
    +/
	public string expiresIn;
    /++
        Contents of the PasteMyst
    +/
	public string code;
	/++
		The automatically detected language of the PasteMyst.
		It is detected when the paste is created.
	+/
	public string language;
}

/++
    Creates a new PasteMyst

    Params:
        code - the contents encoded as a uri component
        expiresIn - when the PasteMyst expires
		language - the language of the paste used by syntax highlighting. possible to be also set to "autodetect" (or "" / null) or "plaintext"

    Returns:
        Structure containing all the info about the created PasteMyst.
+/
public PasteMystInfo createPaste (string code, string expiresIn, string language)
{
	import id : createId;
	import std.uri : decodeComponent;
	import detector : detectLanguage;
	import std.datetime.systime : Clock;
	import vibe.http.common : HTTPStatusException;
	import mysql : Connection, MySQLRow;
	import std.conv : to;
	import db : getConnection, releaseConnection;

	immutable long createdAt = Clock.currTime.toUnixTime;

	if (checkValidExpiryTime (expiresIn) == false)
		throw new HTTPStatusException (400, "Invalid \"expiresIn\" value. Expected: never, 1h, 2h, 10h, 1d, 2d or 1w.");

	Connection connection = getConnection ();

	string id;

	int count;
	
	do
	{
		id = createId ();
		
		count = 0;
		// Do this check in case there is already a paste with the same id
		connection.execute ("select id from PasteMysts where id = ?", id, (MySQLRow row)
		{
			count++;
		});
	} while (count != 0);

	if (language == "autodetect" || language == "" || language == null)
		language = detectLanguage (decodeComponent (code));

	connection.execute ("insert into PasteMysts (id, createdAt, expiresIn, code, language) values (?, ?, ?, ?, ?)",
                         id, to!string (createdAt), expiresIn, code, language);

	connection.releaseConnection ();

	return PasteMystInfo (id, createdAt, expiresIn, code, language);
}

/++
    Gets the PasteMyst with the specified id.

    Returns:
        Structure with all the info about the retrieved PasteMyst. Returns an empty PasteMystInfo struct if the PasteMyst isn't found.
+/
public PasteMystInfo getPaste (string id)
{
	import mysql : Connection, MySQLRow;
	import db : getConnection, releaseConnection;

	Connection connection = getConnection ();

	MySQLRow [] rows;
	connection.execute ("select id, createdAt, expiresIn, code, language from PasteMysts where id = ?", id, (MySQLRow row)
	{
		rows ~= row;
	});

	if (rows.length == 0)
		return PasteMystInfo ();

	MySQLRow row = rows [0];

	connection.releaseConnection ();

	string language = "";

	// If it's null that means this is an older paste (backwards compatibility).
	// If the language is empty then hljs will automatically detect the language.
	if (!row [4].isNull)
		language = row [4].get!string;

	return PasteMystInfo (id, row [1].get!long, row [2].get!string, row [3].get!string, language);
}

/++
    Deletes all PasteMyst which have expired.
+/
public void deleteExpiredPasteMysts ()
{
	import std.array : join;
	import std.format : format;
	import mysql : Connection, MySQLRow;
	import std.datetime.systime : Clock;
	import vibe.core.log : logInfo, logTrace;
	import db : getConnection, releaseConnection;

	try
	{
		string [] pasteMystsToDelete;

		Connection connection = getConnection ();

		connection.execute ("select id, createdAt, expiresIn from PasteMysts where not expiresIn = 'never'",
		(MySQLRow row)
		{
			const string id = row [0].get!string;
			const long createdAt = row [1].get!long;
			const string expiresIn = row [2].get!string;

			long expiresInUnixTime = expiresInToUnixTime (createdAt, expiresIn);

			if (Clock.currTime.toUnixTime > expiresInUnixTime)
				pasteMystsToDelete ~= id;
		});

		if (pasteMystsToDelete.length == 0) return;

		string toDelete;
		for (int i; i < pasteMystsToDelete.length; i++)
		{
			toDelete ~= ("'" ~ pasteMystsToDelete [i] ~ "'");
			if (i + 1 < pasteMystsToDelete.length)
				toDelete ~= ",";
		}
		string deleteQuery = format ("delete from PasteMysts where id in (%s)", toDelete);
		connection.execute (deleteQuery);

		logInfo ("Deleted %s PasteMysts: %s", pasteMystsToDelete.length, toDelete);

		connection.releaseConnection ();
	}
	catch (Exception e)
	{
		logTrace (e.toString);
	}
}

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

/++
    Gets the number of currently active PasteMysts 
+/
public long getNumberOfPastes ()
{
	import mysql : Connection, MySQLRow;
	import db : getConnection, releaseConnection;

	Connection connection = getConnection ();
	MySQLRow countRow;
	connection.execute ("select count(*) from PasteMysts", (MySQLRow row)
	{
		countRow = row;
	});

	connection.releaseConnection ();

	return countRow [0].get!long;
}

/++
    Checks if the provided expiresIn string is a valid expiry string.

    Valid values are: never, 1h, 2h, 10h, 1d, 2d or 1w.
+/
public bool checkValidExpiryTime (string expiresIn)
{
	return (expiresIn == "never" ||
		    expiresIn == "1h"    ||
		    expiresIn == "2h"    ||
		    expiresIn == "10h"   ||
		    expiresIn == "1d"    ||
		    expiresIn == "2d"    ||
		    expiresIn == "1w");
}

unittest
{
	assert (checkValidExpiryTime ("never") == true);
	assert (checkValidExpiryTime ("1h") == true);
	assert (checkValidExpiryTime ("2h") == true);
	assert (checkValidExpiryTime ("10h") == true);
	assert (checkValidExpiryTime ("1d") == true);
	assert (checkValidExpiryTime ("2d") == true);
	assert (checkValidExpiryTime ("1w") == true);
	assert (checkValidExpiryTime ("2d") == true);
	assert (checkValidExpiryTime ("isjadiojsad") == false);
	assert (checkValidExpiryTime ("3h") == false);
	assert (checkValidExpiryTime ("213j98") == false);
	assert (checkValidExpiryTime ("adsj98sdaj") == false);
}
