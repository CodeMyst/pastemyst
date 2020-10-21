module pastemyst.data.config;

import dyaml;

/++
 + struct holding the whole config file
 +/
public struct Config
{
    /++
     + github config for oauth
     +/
    public Github github;

    /++
     + gitlab config for oauth
     +/
    public Gitlab gitlab;

    /++
     + hostname of the website
     +/
    public string hostname;

    /++
     + is the current instance a development one
     +/
    public bool devInstance;

    /++
     + ip on where to host pastemyst
     +/
    public string hostIp;

    /++
     + on which port to host pastemyst
     +/
    public ushort hostPort;

    /++
     + mongodb connection string
     +/
    public string mongoConnection;
}

/++
 + struct holding github oauth id and secret
 +/
public struct Github
{
    /++
     + github client id
     +/
    public string id;

    /++
     + github client secret
     +/
    public string secret;
}

/++
 + struct holding gitlab oauth id and secret
 +/
public struct Gitlab
{
    /++
     + gitlab client id
     +/
    public string id;

    /++
     + gitlab client secret
     +/
    public string secret;
}

/++
 + app config
 +/
@property
@safe
public Config config() { return _config; }
private Config _config;

static this()
{
    version (unittest)
    {
        return;
    }
    else
    {
        import std.file : exists;
        import std.exception : enforce;
        import std.format : format;

        // default configuration file
        string configName = "config.yaml";

        if(!exists(configName))
        {
            // if doesn't exists, fallback to .yml
            configName = "config.yml";
            enforce(exists(configName), format!"missing %s"(configName));
        }

        Node cfg;

        try
        {
            cfg = Loader.fromFile(configName).load();
        }
        catch (YAMLException e)
        {
        	e.msg = format!"%s: invalid or empty"(configName);
        	throw e;
        }

        // TODO: clean this up

        enforce(cfg.isValid(), format!"%s: invalid"(configName));

        enforce(cfg.containsKey("github"), format!"%s: missing github"(configName));

        enforce(cfg["github"].containsKey("id"), format!"%s: missing github id"(configName));
        enforce(cfg["github"].containsKey("secret"), format!"%s: missing github secret"(configName));

        _config.github.id = cfg["github"]["id"].as!string();
        _config.github.secret = cfg["github"]["secret"].as!string();

        enforce(cfg.containsKey("gitlab"), format!"%s: missing gitlab"(configName));

        enforce(cfg["gitlab"].containsKey("id"), format!"%s: missing gitlab id"(configName));
        enforce(cfg["gitlab"].containsKey("secret"), format!"%s: missing gitlab secret"(configName));

        _config.gitlab.id = cfg["gitlab"]["id"].as!string();
        _config.gitlab.secret = cfg["gitlab"]["secret"].as!string();

        enforce(cfg.containsKey("hostname"), format!"%s: missing hostname"(configName));

        _config.hostname = cfg["hostname"].as!string();

        enforce(cfg.containsKey("development_instance"), format!"%s: missing development_instance"(configName));

        _config.devInstance = cfg["development_instance"].as!bool();

        enforce(cfg.containsKey("host_ip"), format!"%s: missing host_ip"(configName));

        _config.hostIp = cfg["host_ip"].as!string();

        enforce(cfg.containsKey("host_port"), format!"%s: missing host_port"(configName));

        _config.hostPort = cfg["host_port"].as!ushort();

        enforce(cfg.containsKey("mongo_connection"), format!"%s: missing mongo_connection"(configName));

        _config.mongoConnection = cfg["mongo_connection"].as!string();
    }
}
