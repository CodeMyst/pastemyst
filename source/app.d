module pastemyst;

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
import mysql;

Connection connection;

Hashids hasher;

shared string dbConnectionString;

void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	string errorDebug = "";
	debug errorDebug = error.debugMessage;
	long numberOfPastes = getNumberOfPastes ();
	res.render!("error.dt", req, error, errorDebug, numberOfPastes);
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
		long numberOfPastes = getNumberOfPastes ();
		render!("index.dt", numberOfPastes);
	}

	// GET /api-docs
	@path ("/api-docs")
	void getApiDocs ()
	{
		long numberOfPastes = getNumberOfPastes ();
		render!("api-docs.dt", numberOfPastes);
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

		long numberOfPastes = getNumberOfPastes ();

		render!("paste.dt", id, createdAt, code, numberOfPastes);
	}
}

PasteMystInfo createPaste (string code, string expiresIn)
{
	import std.random : uniform;

	immutable long createdAt = Clock.currTime.toUnixTime;

	string id = hasher.encode (createdAt, code.length, uniform (0, 10_000));

	if (checkValidExpiryTime (expiresIn) == false)
		throw new HTTPStatusException (400, "Invalid \"expiresIn\" value. Expected: never, 1h, 2h, 10h, 1d, 2d or 1w.");

	connection.execute ("insert into PasteMysts (id, createdAt, expiresIn, code) values (?, ?, ?, ?)", id, to!string (createdAt), expiresIn, code);

	return PasteMystInfo (id, createdAt, expiresIn, code);
}

PasteMystInfo getPaste (string id)
{
	MySQLRow [] rows;
	connection.execute ("select id, createdAt, expiresIn, code from PasteMysts where id = ?", id, (MySQLRow row)
	{
		rows ~= row;
	});

	if (rows.length == 0)
		return PasteMystInfo ();

	MySQLRow row = rows [0];

	return PasteMystInfo (id, row [1].get!long, row [2].get!string, row [3].get!string);
}

long getNumberOfPastes ()
{
	MySQLRow countRow;
	connection.execute ("select count(*) from PasteMysts", (MySQLRow row)
	{
		countRow = row;
	});

	return countRow [0].get!long;
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

void deleteExpiredPasteMysts ()
{
	import std.array : join;
	import std.format : format;

	try
	{
		string [] pasteMystsToDelete;

		MySQLRow [] rows;
		connection.execute ("select id, createdAt, expiresIn, code from PasteMysts where not expiresIn = 'never'", (MySQLRow row)
		{
			rows ~= row;
		});

		foreach (row; rows)
		{
			string id = row [0].get!string;
			long createdAt = row [1].get!long;
			string expiresIn = row [2].get!string;
			string code = row [3].get!string;

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
		}

		if (pasteMystsToDelete.length == 0) return;

		string toDelete;
		for (int i; i < pasteMystsToDelete.length; i++)
		{
			toDelete ~= ("'" ~ pasteMystsToDelete [i] ~ "'");
			if (i != pasteMystsToDelete.length - 1) // stfu
				toDelete ~= ",";
		}
		connection.execute ("delete from PasteMysts where id in (?)", toDelete);

		logInfo ("Deleted %s PasteMysts: %s", pasteMystsToDelete.length, toDelete);
	}
	catch (Exception e)
	{
		logTrace (e.toString);
	}
}

shared bool stopDeleting;

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
	dbConnectionString = appsettings ["mysql"].get!string;

	connection = new Connection (dbConnectionString);

	connection.execute ("create table if not exists PasteMysts (
							id varchar(50) primary key,
							createdAt integer,
							expiresIn text,
							code longtext
						) engine=InnoDB default charset latin1;");

	hasher = new Hashids (appsettings ["hashidsSalt"].get!string);

	scope (exit) stopDeleting = true;
	setTimer (10.minutes, toDelegate (&deleteExpiredPasteMysts), true);

	listenHTTP (settings, router);
	runApplication ();
}

void test ()
{
	long pastes = getNumberOfPastes ();
	logInfo (to!string (pastes));
}