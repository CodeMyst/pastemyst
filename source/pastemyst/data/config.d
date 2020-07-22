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
public Config config() { return _config; }
private Config _config;

private const string configPath = "config.yaml";

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

        if (!exists("config.yaml"))
        {
            throw new Exception("missing config.yaml");
        }

        Node cfg;

        try
        {
            cfg = Loader.fromFile("config.yaml").load();
        }
        catch (YAMLException e)
        {
            throw new Exception("config.yaml: invalid or empty");
        }

        // TODO: clean this up

        enforce(cfg.isValid(), "config.yaml: invalid");

        enforce(cfg.containsKey("github"), "config.yaml: missing github");

        enforce(cfg["github"].containsKey("id"), "config.yaml: missing github id");
        enforce(cfg["github"].containsKey("secret"), "config.yaml: missing github secret");

        _config.github.id = cfg["github"]["id"].as!string();
        _config.github.secret = cfg["github"]["secret"].as!string();

        enforce(cfg.containsKey("gitlab"), "config.yaml: missing gitlab");

        enforce(cfg["gitlab"].containsKey("id"), "config.yaml: missing gitlab id");
        enforce(cfg["gitlab"].containsKey("secret"), "config.yaml: missing gitlab secret");

        _config.gitlab.id = cfg["gitlab"]["id"].as!string();
        _config.gitlab.secret = cfg["gitlab"]["secret"].as!string();

        enforce(cfg.containsKey("hostname"), "config.yaml: missing hostname");

        enforce(cfg.containsKey("development_instance"), "config.yaml: missing development_instance");

        _config.devInstance = cfg["development_instance"].as!bool();
    }
}
