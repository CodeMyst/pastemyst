import ddbc;
import std.stdio;
import vibe.vibe;
import std.string;
import std.datetime;
import vibe.http.router;
import vibe.http.server;
import vibe.http.fileserver;
import std.conv;

const string connectionString = "sqlite:snippets.sqlite";
Connection connection;

void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	res.render!("error.dt", req, error);
}

final class SnippetMyst
{
	// GET /
	void get ()
	{
		render!"index.dt";
	}

	// POST /snippet
	void postSnippet (string code)
	{
		import std.uuid : sha1UUID, UUID;

		UUID uuid = sha1UUID (code);
		string id = uuid.toString;

		auto stmt = connection.createStatement();
		scope(exit) stmt.close();

		long createdAt = Clock.currTime.toUnixTime;

		stmt.executeUpdate("INSERT INTO Snippets (id, createdAt, code) VALUES
							('" ~ id ~ "', " ~ to!string (createdAt) ~ ", '" ~ code ~ "')");

		redirect ("snippet?id=" ~ id.urlEncode);
	}

	// GET /snippet
	void getSnippet (string id)
	{
		auto stmt = connection.createStatement ();
		scope(exit) stmt.close ();

		auto rs = stmt.executeQuery("SELECT id, createdAt, code FROM Snippets WHERE id='" ~ id ~ "'");

		long unixTime;
		string code;

		while (rs.next)
		{
			unixTime = to!long (rs.getLong (2));
			code = to!string (rs.getString (3));
		}

		string createdAt = SysTime.fromUnixTime (unixTime, UTC ()).toLocalTime.toString;

		render!("snippet.dt", id, createdAt, code);
	}
}

void main ()
{
	auto router = new URLRouter;
	router.registerWebInterface (new SnippetMyst);
	router.get ("*", serveStaticFiles ("public"));

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["127.0.0.1", "::1"];
	settings.port = 8080;

    connection = createConnection(connectionString);
    scope(exit) connection.close();

    auto stmt = connection.createStatement();
    scope(exit) stmt.close();

    stmt.executeUpdate("CREATE TABLE IF NOT EXISTS Snippets 
                    (id text not null primary key,
                     createdAt integer,
					 code text)");

	listenHTTP (settings, router);
	runApplication ();
}