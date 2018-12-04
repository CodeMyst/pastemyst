import vibe.vibe;
import hashids;
import mysql;
import mysql.pool;

private Hashids hasher;
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
}

/++
    Interface for the REST API
+/
interface IRestApiInterface
{
    /++
        POST /api/paste
    +/
	@bodyParam ("code", "code")
	@bodyParam ("expiresIn", "expiresIn")
	@method (HTTPMethod.POST)
	@path ("/api/paste")
	Json postPaste (string code, string expiresIn) @safe;

    /++
        GET /api/paste?id={id}
    +/
	@queryParam ("id", "id")
    @method (HTTPMethod.GET)
	@path ("/api/paste")
	Json getPaste (string id) @safe;
}

/++
    Interface for the website
+/
interface IWebInterface
{
    /++
        GET /
    +/
    void get ();

    /++
        GET /api-docs
    +/
	@path ("/api-docs")
    void getApiDocs ();

    /++
        POST /paste
    +/
    void postPaste (string code, string expiresIn);

    /++
        GET /paste?id={id}
    +/
    void getPaste (string id);
}

/++
    REST API Implementation
+/
class RestApiInterface : IRestApiInterface
{
override:
    /++
        POST /api/paste
    +/
	Json postPaste (string code, string expiresIn) @trusted
	{
		return createPaste (code, expiresIn).serializeToJson;
	}

    /++
        GET /api/paste
    +/
	Json getPaste (string id) @trusted
	{
		PasteMystInfo info = pastemyst.getPaste (id);
		
		if (info.id is null)
			throw new HTTPStatusException (404);
		
		return info.serializeToJson;
	}
}

unittest
{
	URLRouter router = new URLRouter;
	registerRestInterface (router, new RestApiInterface);
	auto routes = router.getAllRoutes ();

	assert (routes [0].method == HTTPMethod.POST && routes [0].pattern == "/api/paste");
	assert (routes [1].method == HTTPMethod.GET && routes [1].pattern == "/:id/api/paste");

	auto settings = new HTTPServerSettings;
	settings.port = 5000;
	settings.bindAddresses = ["127.0.0.1"];
	immutable serverAddr = listenHTTP (settings, router).bindAddresses [0];

	auto api = new RestInterfaceClient!IRestApiInterface ("http://" ~ serverAddr.toString);

	initialize ();

	const PasteMystInfo info1 = deserializeJson!PasteMystInfo (api.postPaste ("void%20main%20()%0A%7B%0A%7D", "never"));
	assert (info1.code == "void%20main%20()%0A%7B%0A%7D" && info1.expiresIn == "never");

	const PasteMystInfo info2 = deserializeJson!PasteMystInfo (api.getPaste (info1.id));
	assert (info2.code == "void%20main%20()%0A%7B%0A%7D" && info2.expiresIn == "never" &&
			info2.id == info1.id && info2.createdAt == info1.createdAt);

	deleteDbTable ();
}

/++
    Web Interface Implementation
+/
class WebInterface : IWebInterface
{
override:
    /++
        GET /
    +/
	void get ()
	{
		const long numberOfPastes = getNumberOfPastes ();
		render!("index.dt", numberOfPastes);
	}

    /++
        GET /api-docs
	+/
	@path ("/api-docs")
    void getApiDocs ()
	{
		const long numberOfPastes = getNumberOfPastes ();
		render!("api-docs.dt", numberOfPastes);
	}

    /++
        POST /paste
	+/
    void postPaste (string code, string expiresIn)
	{
		PasteMystInfo info = createPaste (code, expiresIn);

		redirect ("paste?id=" ~ info.id);
	}

    /++
        GET /paste?id={id}
	+/
    void getPaste (string id)
	{
		import std.uri : decodeComponent;

		PasteMystInfo info = pastemyst.getPaste (id);

		if (info.id is null)
			throw new HTTPStatusException (404);

		immutable string createdAt = SysTime.fromUnixTime (info.createdAt, UTC ()).toUTC.toString [0..$-1];
		immutable string code = decodeComponent (info.code);

		const long numberOfPastes = getNumberOfPastes ();

		render!("paste.dt", id, createdAt, code, numberOfPastes);
	}
}

/++
    Creates a new PasteMyst

    Params:
        code - the contents encoded as a uri component
        expiresIn - when the PasteMyst expires

    Returns:
        Structure containing all the info about the created PasteMyst.
+/
PasteMystInfo createPaste (string code, string expiresIn)
{
	import std.random : uniform;

	immutable long createdAt = Clock.currTime.toUnixTime;

	string id = hasher.encode (createdAt, code.length, uniform (0, 10_000));

	if (checkValidExpiryTime (expiresIn) == false)
		throw new HTTPStatusException (400, "Invalid \"expiresIn\" value. Expected: never, 1h, 2h, 10h, 1d, 2d or 1w.");

	Connection connection = connectionPool.getConnection ();

	connection.execute ("insert into " ~ tableName ~ " (id, createdAt, expiresIn, code) values (?, ?, ?, ?)",
                         id, to!string (createdAt), expiresIn, code);

	connectionPool.releaseConnection (connection);

	return PasteMystInfo (id, createdAt, expiresIn, code);
}

/++
    Gets the PasteMyst with the specified id.

    Returns:
        Structure with all the info about the retrieved PasteMyst. Returns an empty PasteMystInfo struct if the PasteMyst isn't found.
+/
PasteMystInfo getPaste (string id)
{
	Connection connection = connectionPool.getConnection ();

	MySQLRow [] rows;
	connection.execute ("select id, createdAt, expiresIn, code from " ~ tableName ~ " where id = ?", id, (MySQLRow row)
	{
		rows ~= row;
	});

	if (rows.length == 0)
		return PasteMystInfo ();

	MySQLRow row = rows [0];

	connectionPool.releaseConnection (connection);

	return PasteMystInfo (id, row [1].get!long, row [2].get!string, row [3].get!string);
}

/++
    Deletes all PasteMyst which have expired.
+/
void deleteExpiredPasteMysts ()
{
	import std.array : join;
	import std.format : format;

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
				default: break;
			}

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

/++
    Gets the number of currently active PasteMysts 
+/
long getNumberOfPastes ()
{
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
	Returns the appsettings.json
+/
Json getAppsettings (string name)
{
	import std.file : readText, exists;
	import std.process : environment;

	// If appsettings.json doesn't exist the use environment variables
	if (!exists (name))
	{
		string host = environment.get ("MYSQL_HOST");
		string user = environment.get ("MYSQL_USER");
		string db = environment.get ("MYSQL_DB");
		string pwd = environment.get ("MYSQL_PWD", "");
		string hashidsSalt = environment.get ("HASHIDS_SALT");

		Json res = Json.emptyObject;
		res ["mysql"] = Json (["host": Json (host), "user": Json (user), "db": Json (db), "pwd": Json (pwd)]);
		res ["hashidsSalt"] = Json (hashidsSalt);

		return res;
	}

	return readText (name).parseJsonString ();
}

/++
	Sets up everything needed to run the app
+/
void initialize ()
{
	initializeDbConnection ();

	createDbTable ();

	createHasher ();
}

/++
	Creates a new DB Connection Pool
+/
private void initializeDbConnection ()
{
	Json appsettings = getAppsettings ("appsettings.json");
	Json mysql = appsettings ["mysql"];

	string host = mysql ["host"].get!string;
	string user = mysql ["user"].get!string;
	string db = mysql ["db"].get!string;

	connectionPool = ConnectionPool.getInstance (host, user, "", db);
}

/++
	Creates a new DB Table if it doesn't exist
+/
private void createDbTable ()
{
	Connection connection = connectionPool.getConnection ();

	connection.execute ("create table if not exists " ~ tableName ~ " (
							id varchar(50) primary key,
							createdAt integer,
							expiresIn text,
							code longtext
						) engine=InnoDB default charset latin1;");

	connectionPool.releaseConnection (connection);
}

/++
	Deletes the DB Table. Only called for tests
+/
private void deleteDbTable ()
{
	Connection connection = connectionPool.getConnection ();

	connection.execute ("drop table " ~ tableName);

	connectionPool.releaseConnection (connection);
}

/++
	Creates a new hasher that generates unique IDs
+/
private void createHasher ()
{
	Json appsettings = getAppsettings ("appsettings.json");
	hasher = new Hashids (appsettings ["hashidsSalt"].get!string);
}
