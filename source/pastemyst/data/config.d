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
     + jwt config
     +/
    public Jwt jwt;

    /++
     + redis config
     +/
    public Redis redis;
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
 + redis config
 +/
public struct Redis
{
    /++
     + redis host string
     +/
    public string host;

    /++
     + redis db index
     +/
    public ulong index;
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

        enforce(cfg.containsKey("gitlab"), "config.yaml: missing gitlab");

        enforce(cfg["gitlab"].containsKey("id"), "config.yaml: missing gitlab id");
        enforce(cfg["gitlab"].containsKey("secret"), "config.yaml: missing gitlab secret");

        _config.gitlab.id = cfg["gitlab"]["id"].as!string();
        _config.gitlab.secret = cfg["gitlab"]["secret"].as!string();

        enforce(cfg.containsKey("jwt"), "config.yaml: missing jwt");

        enforce(cfg["jwt"].containsKey("secret"), "config.yaml: missing jwt secret");

        _config.jwt.secret = cfg["jwt"]["secret"].as!string();

        enforce(cfg.containsKey("redis"), "config.yaml: missing redis");

        enforce(cfg["redis"].containsKey("host"), "config.yaml: missing redis host");
        enforce(cfg["redis"].containsKey("index"), "config.yaml: missing redis db index");

        _config.redis.host = cfg["redis"]["host"].as!string();
        _config.redis.index = cfg["redis"]["index"].as!ulong();
    }
}
