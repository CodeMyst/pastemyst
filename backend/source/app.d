import vibe.d;

public void main()
{
    auto router = new URLRouter();

    auto fsettings = new HTTPFileServerSettings();
    fsettings.serverPathPrefix = "/static";

    router.get("/static/*", serveStaticFiles("../public/", fsettings));

    auto serverSettings = new HTTPServerSettings();
    serverSettings.bindAddresses = ["127.0.0.1"];
    serverSettings.port = 5005;

    listenHTTP(serverSettings, router);
    runApplication();
}
