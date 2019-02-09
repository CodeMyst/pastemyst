module pastemyst;

import mysql.pool : ConnectionPool;

private ConnectionPool connectionPool;

version (unittest)
	private const string tableName = "Test";
else
	private const string tableName = "PasteMysts";

/++
    Structure that contains all info about a PasteMyst
+/
struct PasteMystInfo
{
    /++
        ID of the PasteMyst
    +/
	string id;
    /++
        When the PasteMyst is created, in UNIX time
    +/
	long createdAt;
    /++
        When the PasteMyst expires. Valid values are: never, 1h, 2h, 10h, 1d, 2d or 1w
    +/
	string expiresIn;
    /++
        Contents of the PasteMyst
    +/
	string code;
	/++
		The automatically detected language of the PasteMyst.
		It is detected when the paste is created.
	+/
	string language;
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
PasteMystInfo createPaste (string code, string expiresIn, string language)
{
	import id : createId;
	import std.uri : decodeComponent;
	import detector : detectLanguage;
	import std.datetime.systime : Clock;
	import vibe.http.common : HTTPStatusException;
	import mysql : Connection, MySQLRow;
	import std.conv : to;

	immutable long createdAt = Clock.currTime.toUnixTime;

	if (checkValidExpiryTime (expiresIn) == false)
		throw new HTTPStatusException (400, "Invalid \"expiresIn\" value. Expected: never, 1h, 2h, 10h, 1d, 2d or 1w.");

	Connection connection = connectionPool.getConnection ();

	string id;

	int count;
	
	do
	{
		id = createId ();
		
		count = 0;
		// Do this check in case there is already a paste with the same id
		connection.execute ("select id from " ~ tableName ~ " where id = ?", id, (MySQLRow row)
		{
			count++;
		});
	} while (count != 0);

	if (language == "autodetect" || language == "" || language == null)
		language = detectLanguage (decodeComponent (code));

	connection.execute ("insert into " ~ tableName ~ " (id, createdAt, expiresIn, code, language) values (?, ?, ?, ?, ?)",
                         id, to!string (createdAt), expiresIn, code, language);

	connectionPool.releaseConnection (connection);

	return PasteMystInfo (id, createdAt, expiresIn, code, language);
}

/++
    Gets the PasteMyst with the specified id.

    Returns:
        Structure with all the info about the retrieved PasteMyst. Returns an empty PasteMystInfo struct if the PasteMyst isn't found.
+/
PasteMystInfo getPaste (string id)
{
	import mysql : Connection, MySQLRow;

	Connection connection = connectionPool.getConnection ();

	MySQLRow [] rows;
	connection.execute ("select id, createdAt, expiresIn, code, language from " ~ tableName ~ " where id = ?", id, (MySQLRow row)
	{
		rows ~= row;
	});

	if (rows.length == 0)
		return PasteMystInfo ();

	MySQLRow row = rows [0];

	connectionPool.releaseConnection (connection);

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
void deleteExpiredPasteMysts ()
{
	import std.array : join;
	import std.format : format;
	import mysql : Connection, MySQLRow;
	import std.datetime.systime : Clock;
	import vibe.core.log : logInfo, logTrace;

	try
	{
		string [] pasteMystsToDelete;

		Connection connection = connectionPool.getConnection ();

		connection.execute ("select id, createdAt, expiresIn from " ~ tableName ~ " where not expiresIn = 'never'",
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
		string deleteQuery = format ("delete from %s where id in (%s)", tableName, toDelete);
		connection.execute (deleteQuery);

		logInfo ("Deleted %s PasteMysts: %s", pasteMystsToDelete.length, toDelete);

		connectionPool.releaseConnection (connection);
	}
	catch (Exception e)
	{
		logTrace (e.toString);
	}
}

long expiresInToUnixTime (long createdAt, string expiresIn)
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
long getNumberOfPastes ()
{
	import mysql : Connection, MySQLRow;

	Connection connection = connectionPool.getConnection ();
	MySQLRow countRow;
	connection.execute ("select count(*) from " ~ tableName, (MySQLRow row)
	{
		countRow = row;
	});

	connectionPool.releaseConnection (connection);

	return countRow [0].get!long;
}

/++
    Checks if the provided expiresIn string is a valid expiry string.

    Valid values are: never, 1h, 2h, 10h, 1d, 2d or 1w.
+/
bool checkValidExpiryTime (string expiresIn)
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

/++
	Sets up everything needed to run the app
+/
void initialize ()
{
	initializeDbConnection ();

	createDbTable ();
}

/++
	Creates a new DB Connection Pool
+/
void initializeDbConnection ()
{
	import appsettings : MySQLSettings, getMySQLSettings;

	auto settings = getMySQLSettings ();

	connectionPool = ConnectionPool.getInstance (settings.host, settings.user, settings.pwd, settings.db);
}

/++
	Creates a new DB Table if it doesn't exist
+/
void createDbTable ()
{
	import mysql : Connection;

	Connection connection = connectionPool.getConnection ();

	connection.execute ("create table if not exists " ~ tableName ~ " (
							id varchar(50) primary key,
							createdAt integer,
							expiresIn text,
							code longtext,
							language text
						) engine=InnoDB default charset latin1;");

	connectionPool.releaseConnection (connection);
}

/++
	Deletes the DB Table. Only called for tests
+/
void deleteDbTable ()
{
	import mysql : Connection;

	Connection connection = connectionPool.getConnection ();

	connection.execute ("drop table " ~ tableName);

	connectionPool.releaseConnection (connection);
}
