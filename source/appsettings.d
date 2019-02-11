module appsettings;

import vibe.data.serialization;
import vibe.data.json;

private const string appsettingsPath = "appsettings.json";

public struct MySQLSettings
{
    string host;
    string user;
    string db;
    @optional
    string pwd;
}

public struct GitHubSettings
{
    string clientId;
    string clientSecret;
}

/++
	Returns MySQL settings
+/
public MySQLSettings getMySQLSettings ()
{
	import std.file : readText, exists;
	import std.process : environment;

	// If appsettings.json doesn't exist then use environment variables
	if (!exists (appsettingsPath))
	{
		string host = environment.get ("MYSQL_HOST");
		string user = environment.get ("MYSQL_USER");
		string db = environment.get ("MYSQL_DB");
		string pwd = environment.get ("MYSQL_PWD", "");

        return MySQLSettings (host, user, db, pwd);
	}

    Json json = readText (appsettingsPath).parseJsonString ();
    return deserializeJson!MySQLSettings (json ["mysql"]);
}

public GitHubSettings getGitHubSettings ()
{
    import std.file : readText;

    Json json = readText (appsettingsPath).parseJsonString ();

    return deserializeJson!GitHubSettings (json ["github"]);
}