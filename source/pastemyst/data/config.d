module pastemyst.data.config;

import dyaml;
import yamlserialized;

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
    @YamlField("development_instance")
    public bool devInstance;

    /++
     + ip on where to host pastemyst
     +/
    @YamlField("host_ip")
    public string hostIp;

    /++
     + on which port to host pastemyst
     +/
    @YamlField("host_port")
    public ushort hostPort;

    /++
     + mongodb connection string
     +/
    @YamlField("mongo_connection")
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

        cfg.deserializeInto(_config);
    }
}
