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

const string connectionString = "sqlite:pastemysts.sqlite";
SQLITEConnection connection;

void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	res.render!("error.dt", req, error);
}

final class PasteMyst
{
	// GET /
	void get ()
	{
		render!"index.dt";
	}

	// POST /paste
	void postPaste (string code)
	{
		auto stmt = connection.createStatement();
		scope(exit) stmt.close();

		immutable long createdAt = Clock.currTime.toUnixTime;

		stmt.executeUpdate("INSERT INTO PasteMysts (createdAt, code) VALUES
							(" ~ to!string (createdAt) ~ ", \"" ~ code ~ "\")");

		sqlite3_int64 id = sqlite3_last_insert_rowid (connection.getConnection ());

		redirect ("paste?id=" ~ to!string (id));
	}

	// GET /paste
	void getPaste (long id)
	{
		auto stmt = connection.createStatement ();
		scope(exit) stmt.close ();

		auto rs = stmt.executeQuery("SELECT id, createdAt, code FROM PasteMysts WHERE id='" ~ to!string (id) ~ "'");

		long unixTime;
		string code;

		while (rs.next)
		{
			unixTime = to!long (rs.getLong (2));
			code = decode (to!string (rs.getString (3)));
		}

		immutable string createdAt = SysTime.fromUnixTime (unixTime, UTC ()).toUTC.toString [0..$-1];

		render!("paste.dt", id, createdAt, code);
	}
}

void main ()
{
	auto router = new URLRouter;
	router.registerWebInterface (new PasteMyst);
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