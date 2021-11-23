import vibe.d;
import poodinis;
import services;
import api;

void main()
{
    auto config = new ConfigService();
    auto langs = new LangService();

    auto dependencies = new shared DependencyContainer();
    dependencies.register!ConfigService().existingInstance(config);
    dependencies.register!LangService().existingInstance(langs);

    dependencies.register!MongoDBService();
    dependencies.register!PasteService();

    dependencies.register!DataController();
    dependencies.register!PasteController();

    auto router = new URLRouter();

    router.registerRestInterface(dependencies.resolve!DataController());
    router.registerRestInterface(dependencies.resolve!PasteController());

    auto serverSettings = new HTTPServerSettings();
    serverSettings.bindAddresses = [config.hostIp];
    serverSettings.port = config.hostPort;

    listenHTTP(serverSettings, router);

    runApplication();
}
