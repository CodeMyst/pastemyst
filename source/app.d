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

MySQLClient mysqlClient;
// TODO: Figure out how to not use this long type
LockedConnection!(Connection!(VibeSocket, cast (ConnectionOptions) 0)*) connection;

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

	// GET /api-docs
	@path ("/api-docs")
	void getApiDocs ()
	{
		render!"api-docs.dt";
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
		immutable string code = decodeComponent (info.code);

		render!("paste.dt", id, createdAt, code);
	}
}

PasteMystInfo createPaste (string code)
{
	immutable long createdAt = Clock.currTime.toUnixTime;

	connection.execute ("insert into PasteMysts (createdAt, code) values
						 (" ~ to!string (createdAt) ~ ", \"" ~ code ~ "\")");

	const long id = connection.insertID;

	return PasteMystInfo (id, createdAt, code);
}

PasteMystInfo getPaste (long id)
{
	PasteMystInfo info;
	
	connection.execute ("select id, createdAt, code from PasteMysts where id='" ~ to!string (id) ~ "'", (MySQLRow row)
	{
		info = row.toStruct!PasteMystInfo;
	});

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

	string jsonContent = readText ("appsettings.json");
	Json appsettings = jsonContent.parseJsonString ();

	mysqlClient = new MySQLClient (appsettings ["dbConnection"].get!string);
	connection = mysqlClient.lockConnection;

    connection.execute ("create table if not exists PasteMysts (
							id bigint auto_increment primary key,
							createdAt integer,
							code longtext
						) engine=InnoDB default charset latin1;");

	listenHTTP (settings, router);
	runApplication ();
}