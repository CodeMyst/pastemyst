module pastemyst;

import mysql;
import std.stdio;
import vibe.vibe;
import std.string;
import std.datetime;
import vibe.http.router;
import vibe.http.server;
import vibe.http.fileserver;
import std.conv;
import std.uri;
import std.base64;
import hashids;
import std.file;
import vibe.core.connectionpool;
import core.thread;

Connection connection;

Hashids hasher;

shared string dbConnectionString;

void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	string errorDebug = "";
	debug errorDebug = error.debugMessage;
	res.render!("error.dt", req, error, errorDebug);
}

interface IRest
{
	@bodyParam ("code", "code")
	@bodyParam ("expiresIn", "expiresIn")
	@method (HTTPMethod.POST)
	@path ("/api/paste")
	Json postPaste (string code, string expiresIn) @safe;

	@queryParam ("id", "id")
	Json getPaste (string id) @safe;
}

@rootPathFromName
class Api : IRest
{
	Json postPaste (string code, string expiresIn) @trusted
	{
		return createPaste (code, expiresIn).serializeToJson;
	}

	Json getPaste (string id) @trusted
	{
		PasteMystInfo info = pastemyst.getPaste (id);
		
		if (info.id is null)
			throw new HTTPStatusException (404);
		
		return info.serializeToJson;
	}
}

class PasteMyst
{
	// GET /
	void get ()
	{
		render!"index.dt";
	}

	// GET /api-docs
	@path ("/api-docs")
	void getApiDocs ()
	{
		render!"api-docs.dt";
	}

	// POST /paste
	void postPaste (string code, string expiresIn)
	{
		PasteMystInfo info = createPaste (code, expiresIn);

		redirect ("paste?id=" ~ info.id);
	}

	// GET /paste
	void getPaste (string id)
	{
		PasteMystInfo info = pastemyst.getPaste (id);

		if (info.id is null)
			throw new HTTPStatusException (404);

		immutable string createdAt = SysTime.fromUnixTime (info.createdAt, UTC ()).toUTC.toString [0..$-1];
		immutable string code = decodeComponent (info.code);

		render!("paste.dt", id, createdAt, code);
	}
}

PasteMystInfo createPaste (string code, string expiresIn)
{
	import std.random : uniform;

	immutable long createdAt = Clock.currTime.toUnixTime;

	string id = hasher.encode (createdAt, code.length, uniform (0, 10_000));

	if (checkValidExpiryTime (expiresIn) == false)
		throw new HTTPStatusException (400, "Invalid \"expiresIn\" value. Expected: never, 1h, 2h, 10h, 1d, 2d or 1w.");

	Prepared prepared = connection.prepare ("insert into PasteMysts (id, createdAt, expiresIn, code) values (?, ?, ?, ?)");
	prepared.setArgs (id, to!string (createdAt), expiresIn, code);

	connection.exec (prepared);

	return PasteMystInfo (id, createdAt, expiresIn, code);
}

PasteMystInfo getPaste (string id)
{
	Prepared prepared = connection.prepare ("select id, createdAt, expiresIn, code from PasteMysts where id = ?");
	prepared.setArgs (id);

	ResultRange result = connection.query (prepared);

	if (result.empty)
		return PasteMystInfo ();

	Row row = result.front;

	return PasteMystInfo (id, row [1].get!long, row [2].get!string, row [3].get!string);
}

bool checkValidExpiryTime (string expiresIn)
{
	if (expiresIn == "never" ||
		expiresIn == "1h" ||
		expiresIn == "2h" ||
		expiresIn == "10h" ||
		expiresIn == "1d" ||
		expiresIn == "2d" ||
		expiresIn == "1w")
	{
		return true;
	}
	else
	{
		return false;
	}
}

struct PasteMystInfo
{
	string id;
	long createdAt;
	string expiresIn;
	string code;
}

shared bool stopDeletingEntries;

void deleteExpiredEntries ()
{
	while (!stopDeletingEntries)
	{
		Thread.sleep (dur!("minutes") (10));

		del ();
	}
}

void del ()
{
	import std.array : join;

	try
	{
		string [] pasteMystsToDelete;

		Connection con = new Connection (dbConnectionString);
		scope (exit) con.close ();

		Prepared prepared = con.prepare ("select id, createdAt, expiresIn, code from PasteMysts where not expiresIn = 'never'");

		ResultRange result = con.query (prepared);

		while (!result.empty)
		{
			string id = result.front [0].get!string;
			long createdAt = result.front [1].get!long;
			string expiresIn = result.front [2].get!string;
			string code = result.front [3].get!string;

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
			{
				pasteMystsToDelete ~= id;
			}

			result.popFront ();
		}

		Prepared preparedDelete = con.prepare ("delete from PasteMysts where id in (?)");
		preparedDelete.setArgs (join (pasteMystsToDelete, ","));
		con.exec (preparedDelete);
	}
	catch (Exception e)
	{
		writeln (e.toString);
	}
}

void main ()
{
	auto router = new URLRouter;
	router.registerWebInterface (new PasteMyst);
	router.registerRestInterface (new Api);
	router.get ("*", serveStaticFiles ("public"));

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["127.0.0.1", "::1"];
	settings.port = 5000;
	settings.errorPageHandler = toDelegate (&showError);

	string jsonContent = readText ("appsettings.json");
	Json appsettings = jsonContent.parseJsonString ();
	dbConnectionString = appsettings ["dbConnection"].get!string;

	connection = new Connection (appsettings ["dbConnection"].get!string);
	scope (exit) connection.close ();

	connection.exec ("create table if not exists PasteMysts (
							id varchar(50) primary key,
							createdAt integer,
							expiresIn text,
							code longtext
						) engine=InnoDB default charset latin1;");

	hasher = new Hashids (appsettings ["hashidsSalt"].get!string);

	auto threadId = spawn (&deleteExpiredEntries);
	scope (exit) stopDeletingEntries = true;

	// del ();

	listenHTTP (settings, router);
	runApplication ();
}