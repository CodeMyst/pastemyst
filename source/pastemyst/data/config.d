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
     + jwt config
     +/
    public Jwt jwt;
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
 + struct holding the jwt secret
 +/
public struct Jwt
{
    /++
     + jwt secret
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

        enforce(cfg.isValid(), "config.yaml: invalid");

        enforce(cfg.containsKey("github"), "config.yaml: missing github");

        enforce(cfg["github"].containsKey("id"), "config.yaml: missing github id");
        enforce(cfg["github"].containsKey("secret"), "config.yaml: missing github secret");

        _config.github.id = cfg["github"]["id"].as!string();
        _config.github.secret = cfg["github"]["secret"].as!string();

        enforce(cfg.containsKey("jwt"), "config.yaml: missing jwt");

        enforce(cfg["jwt"].containsKey("secret"), "config.yaml: missing jwt secret");

        _config.jwt.secret = cfg["jwt"]["secret"].as!string();
    }
}
