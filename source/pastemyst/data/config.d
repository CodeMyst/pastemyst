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
 + app config
 +/
@property
public Config config() { return _config; }
private Config _config;

private const string configPath = "config.yaml";

static this()
{
    import std.file : exists;

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

    if (!cfg.isValid())
    {
        throw new Exception("config.yaml: invalid");
    }

    if (!cfg.containsKey("github"))
    {
        throw new Exception("config.yaml: missing github");
    }

    if (!cfg["github"].containsKey("id") || !cfg["github"].containsKey("secret"))
    {
        throw new Exception("config.yaml: missing github id or github secret");
    }

    _config.github.id = cfg["github"]["id"].as!string();
    _config.github.secret = cfg["github"]["secret"].as!string();
}
