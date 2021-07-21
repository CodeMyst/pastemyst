import vibe.d;

import pastemyst.request.router;

import pastemyst.api.v3.data;

public void main()
{
    auto serverSettings = new HTTPServerSettings();
    serverSettings.bindAddresses = ["127.0.0.1"];
    serverSettings.port = 5005;

    registerApiRoutes(DataApi());

    listenHTTP(serverSettings, &handleRequest);
    runApplication();
}
