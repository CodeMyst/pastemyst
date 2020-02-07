import vibe.vibe;
import mysql;

private string connectionString;

static this ()
{
	Json appsettings = getAppsettings ("appsettings.json");
	Json mysql = appsettings ["mysql"];

	string host = mysql ["host"].get!string;
	string user = mysql ["user"].get!string;
	string db = mysql ["db"].get!string;

	connectionString = "host=" ~ host ~ ";user=" ~ user ~ ";db=" ~ db;
}

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
    Interface for the REST API
+/
interface IRestApiInterface
{
    /++
        POST /api/paste
    +/
	@bodyParam ("code", "code")
	@bodyParam ("expiresIn", "expiresIn")
	@bodyParam ("language", "language")
	@method (HTTPMethod.POST)
	@path ("/api/paste")
	Json postPaste (string code, string expiresIn, string language = "autodetect") @safe;

    /++
        GET /api/paste?id={id}
    +/
	@queryParam ("id", "id")
    @method (HTTPMethod.GET)
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
    void postPaste (string code, string expiresIn, string language);

    /++
        GET /paste?id={id}
    +/
    void getPaste (string id);

	/++
		GET /:id

		This function has to be later than getPaste (string)!
	+/
	@path("/:id")
	@method (HTTPMethod.GET)
	void getPaste (HTTPServerRequest req, HTTPServerResponse);
}

/++
    REST API Implementation
+/
@rootPathFromName
class RestApiInterface : IRestApiInterface
{
override:
    /++
        POST /api/paste
    +/
	Json postPaste (string code, string expiresIn, string language) @trusted
	{
		return createPaste (code, expiresIn, language).serializeToJson;
	}

    /++
        GET /api/paste?id={id}
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
	assert (routes [1].method == HTTPMethod.GET && routes [1].pattern == "/:id/paste");

	auto settings = new HTTPServerSettings;
	settings.port = 5000;
	settings.bindAddresses = ["127.0.0.1"];
	immutable serverAddr = listenHTTP (settings, router).bindAddresses [0];

	auto api = new RestInterfaceClient!IRestApiInterface ("http://" ~ serverAddr.toString);

	initialize ();

	const PasteMystInfo info1 = deserializeJson!PasteMystInfo (api.postPaste ("void%20main%20()%0A%7B%0A%7D", "never", "d"));
	assert (info1.code == "void%20main%20()%0A%7B%0A%7D" && info1.expiresIn == "never" && info1.language == "d");

	const PasteMystInfo info2 = deserializeJson!PasteMystInfo (api.getPaste (info1.id));
	assert (info2.code == "void%20main%20()%0A%7B%0A%7D" && info2.expiresIn == "never" &&
			info2.id == info1.id && info2.createdAt == info1.createdAt && info2.language == "d");

	deleteDbTable ();
}

/++
    Web Interface Implementation
+/
class WebInterface : IWebInterface
{
    /++
        GET /
    +/
	override void get ()
	{
		const long numberOfPastes = getNumberOfPastes ();
		render!("index.dt", numberOfPastes);
	}

    /++
        GET /api-docs
	+/
	@path ("/api-docs")
    override void getApiDocs ()
	{
		const long numberOfPastes = getNumberOfPastes ();
		render!("api-docs.dt", numberOfPastes);
	}

    /++
        POST /paste
	+/
    override void postPaste (string code, string expiresIn, string language)
	{
		PasteMystInfo info = createPaste (code, expiresIn, language);

		redirect ("/" ~ info.id);
	}

    /++
        GET /paste?id={id}

		NOTE: This is kept for backwards compatibility, you should get the paste with /:id
	+/
    override void getPaste (string id)
	{
		import std.uri : decodeComponent;

		PasteMystInfo info = pastemyst.getPaste (id);

		if (info.id is null)
			throw new HTTPStatusException (404);

		immutable string createdAt = SysTime.fromUnixTime (info.createdAt, UTC ()).toUTC.toString [0..$-1];
		
		string expiresAt;
		if (info.expiresIn == "never")
		{
			expiresAt = "never";
		}
		else
		{
			expiresAt = SysTime.fromUnixTime (expiresInToUnixTime (info.createdAt, info.expiresIn), UTC ())
						.toUTC.toString [0..$-1];
		}

		immutable string code = decodeComponent (info.code);

		const long numberOfPastes = getNumberOfPastes ();

		const string language = info.language;

		render!("paste.dt", id, createdAt, code, numberOfPastes, expiresAt, language);
	}

	/++
		GET /:id

		This function has to be later than getPaste (string)!
	+/
	@path("/:id")
	override void getPaste (HTTPServerRequest req, HTTPServerResponse)
	{
		string id = req.params ["id"];

		return getPaste (id);
	}
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
	import std.array : array;

	immutable long createdAt = Clock.currTime.toUnixTime;

	if (checkValidExpiryTime (expiresIn) == false)
		throw new HTTPStatusException (400, "Invalid \"expiresIn\" value. Expected: never, 1h, 2h, 10h, 1d, 2d, 1w, 1m or 1y.");

    if (checkValidLanguage (language) == false)
        throw new HTTPStatusException (400, "Invalid \"language\" value.");

	Connection connection = createConnection ();

	string id;

	int count;
	
	do
	{
		id = createId ();
		
		count = 0;
		// Do this check in case there is already a paste with the same id
		count += connection.query ("select id from " ~ tableName ~ " where id = ?", id).array.length;
	} while (count != 0);

	if (language == "autodetect" || language == "" || language == null)
		language = detectLanguage (decodeComponent (code));

	connection.exec ("insert into " ~ tableName ~ " (id, createdAt, expiresIn, code, language) values (?, ?, ?, ?, ?)",
                     id, to!string (createdAt), expiresIn, code, language);

	connection.close ();

	return PasteMystInfo (id, createdAt, expiresIn, code, language);
}

/++
    Gets the PasteMyst with the specified id.

    Returns:
        Structure with all the info about the retrieved PasteMyst. Returns an empty PasteMystInfo struct if the PasteMyst isn't found.
+/
PasteMystInfo getPaste (string id)
{
	import std.array : array;

	Connection connection = createConnection ();

	Row [] rows = connection.query ("select id, createdAt, expiresIn, code, language from " ~ tableName ~ " where id = ?", id).array;

	if (rows.length == 0)
		return PasteMystInfo ();

	Row row = rows [0];

	string language = "";

	// If it's null that means this is an older paste (backwards compatibility).
	// If the language is empty then hljs will automatically detect the language.
	if (row [4].type != typeid (typeof (null)))
		language = row [4].get!string;

	connection.close ();

	return PasteMystInfo (id, row [1].get!long, row [2].get!string, row [3].get!string, language);
}

/++
    Deletes all PasteMyst which have expired.
+/
void deleteExpiredPasteMysts ()
{
	import std.array : join, array;
	import std.format : format;

	try
	{
		string [] pasteMystsToDelete;

		Connection connection = createConnection ();

		Row [] rows = connection.query ("select id, createdAt, expiresIn from " ~ tableName ~ " where not expiresIn = 'never'").array;
		
		foreach (row; rows)
		{
			const string id = row [0].get!string;
			const long createdAt = row [1].get!long;
			const string expiresIn = row [2].get!string;

			long expiresInUnixTime = expiresInToUnixTime (createdAt, expiresIn);

			if (Clock.currTime.toUnixTime > expiresInUnixTime)
				pasteMystsToDelete ~= id;
		}

		if (pasteMystsToDelete.length == 0) return;

		string toDelete;
		for (int i; i < pasteMystsToDelete.length; i++)
		{
			toDelete ~= ("'" ~ pasteMystsToDelete [i] ~ "'");
			if (i + 1 < pasteMystsToDelete.length)
				toDelete ~= ",";
		}
		string deleteQuery = format ("delete from %s where id in (%s)", tableName, toDelete);
		connection.exec (deleteQuery);

		logInfo ("Deleted %s PasteMysts: %s", pasteMystsToDelete.length, toDelete);

		connection.close ();
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
		case "1m":
			expiresInUnixTime += 2_629_800;
			break;
		case "1y":
			expiresInUnixTime += 31_557_600;
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
	import std.array : array;

	Connection connection = createConnection ();
	Row countRow = connection.query ("select count(*) from " ~ tableName).array [0];

	connection.close ();

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
		    expiresIn == "1w"	 ||
			expiresIn == "1m"    ||
			expiresIn == "1y");
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
	assert (checkValidExpiryTime ("1m") == true);
	assert (checkValidExpiryTime ("1y") == true);
	assert (checkValidExpiryTime ("isjadiojsad") == false);
	assert (checkValidExpiryTime ("3h") == false);
	assert (checkValidExpiryTime ("213j98") == false);
	assert (checkValidExpiryTime ("adsj98sdaj") == false);
}

bool checkValidLanguage (string language)
{
    import std.file : readText, getcwd;
    import std.string : splitLines;

    string [] validLanguages = readText (getcwd () ~ "/public/languages.txt").splitLines ();

    foreach (lang; validLanguages)
    {
        if (language == lang)
            return true;
    }

    return false;
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

		Json res = Json.emptyObject;
		res ["mysql"] = Json (["host": Json (host), "user": Json (user), "db": Json (db), "pwd": Json (pwd)]);

		return res;
	}

	return readText (name).parseJsonString ();
}

/++
	Sets up everything needed to run the app
+/
void initialize ()
{
	createDbTable ();
}

/++
	Creates a new DB Connection Pool
+/
private Connection createConnection ()
{
	return new Connection (connectionString);
}

/++
	Creates a new DB Table if it doesn't exist
+/
private void createDbTable ()
{
	Connection connection = createConnection ();

	connection.exec ("create table if not exists " ~ tableName ~ " (
							id varchar(50) primary key,
							createdAt integer,
							expiresIn text,
							code longtext,
							language text
						) engine=InnoDB default charset latin1;");

	connection.close ();
}

/++
	Deletes the DB Table. Only called for tests
+/
private void deleteDbTable ()
{
	Connection connection = createConnection ();

	connection.exec ("drop table " ~ tableName);

	connection.close ();
}
