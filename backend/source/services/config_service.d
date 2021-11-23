module services.config_service;

import dyaml;
import yamlserialized;

@safe:

public class ConfigService
{
    @YamlField("host_ip")
    public string hostIp;

    @YamlField("host_port")
    public ushort hostPort;

    @YamlField("mongo_connection")
    public string mongoConnection;

    @YamlField("mongo_database")
    public string mongoDatabase;

    public this()
    {
        Node configYml = Loader.fromFile("config.yml").load();
        configYml.deserializeInto(this);
    }
}

