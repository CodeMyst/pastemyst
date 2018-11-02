module pastemyst;

import ddbc;
import std.stdio;
import vibe.vibe;
import std.string;
import std.datetime;
import vibe.http.router;
import vibe.http.server;
import vibe.http.fileserver;
import std.conv;
import etc.c.sqlite3;
import ddbc.drivers.sqliteddbc;
import std.uri;
import std.base64;

const string connectionString = "sqlite:pastemysts.sqlite";
SQLITEConnection connection;

void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	res.render!("error.dt", req, error);
}

interface IRest
{
	@bodyParam ("code", "code")
	@method (HTTPMethod.POST)
	@path ("/api/paste")
	Json postPaste (string code) @safe;

	@queryParam ("id", "id")
	Json getPaste (long id) @safe;
}

@rootPathFromName
class Api : IRest
{
	Json postPaste (string code) @trusted
	{
		return createPaste (code).serializeToJson;
	}

	Json getPaste (long id) @trusted
	{
		return pastemyst.getPaste (id).serializeToJson;
	}
}

class PasteMyst
{
	// GET /
	void get ()
	{
		render!"index.dt";
	}

	// POST /paste
	void postPaste (string code)
	{
		PasteMystInfo info = createPaste (code);

		redirect ("paste?id=" ~ to!string (info.id));
	}

	// GET /paste
	void getPaste (long id)
	{
		PasteMystInfo info = pastemyst.getPaste (id);

		immutable string createdAt = SysTime.fromUnixTime (info.createdAt, UTC ()).toUTC.toString [0..$-1];
		immutable string code = cast (string) Base64.decode (info.code);

		render!("paste.dt", id, createdAt, code);
	}
}

PasteMystInfo createPaste (string code)
{
	auto stmt = connection.createStatement ();
	scope (exit) stmt.close ();

	immutable long createdAt = Clock.currTime.toUnixTime;

	stmt.executeUpdate ("INSERT INTO PasteMysts (createdAt, code) VALUES
						(" ~ to!string (createdAt) ~ ", \"" ~ code ~ "\")");

	sqlite3_int64 id = sqlite3_last_insert_rowid (connection.getConnection ());

	return PasteMystInfo (id, createdAt, code);
}

PasteMystInfo getPaste (long id)
{
	auto stmt = connection.createStatement ();
	scope(exit) stmt.close ();

	auto rs = stmt.executeQuery("SELECT id, createdAt, code FROM PasteMysts WHERE id='" ~ to!string (id) ~ "'");

	PasteMystInfo info;
	info.id = id;

	while (rs.next)
	{
		info.createdAt = to!long (rs.getLong (2));
		info.code = to!string (rs.getString (3));
	}

	return info;
}

struct PasteMystInfo
{
	long id;
	long createdAt;
	string code;
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

    connection = cast (SQLITEConnection) createConnection (connectionString);
    scope (exit) connection.close();

    auto stmt = connection.createStatement ();
    scope (exit) stmt.close ();

    stmt.executeUpdate ("CREATE TABLE IF NOT EXISTS PasteMysts 
                       (id integer primary key,
                        createdAt integer,
					    code text)");

	listenHTTP (settings, router);
	runApplication ();
}