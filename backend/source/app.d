import vibe.d;

import pastemyst.request.router;

import pastemyst.api.v3.data;

public void main()
{
    auto serverSettings = new HTTPServerSettings();
    serverSettings.bindAddresses = ["127.0.0.1"];
    serverSettings.port = 5005;

    registerApiRoutes(DataApi());

    listenHTTP(serverSettings, &handleRequests);
    runApplication();
}

private void handleRequests(HTTPServerRequest req, HTTPServerResponse res)
{
     auto routes = matchApiRoutes(req);

    foreach (route; routes)
    {
        auto ret = route.handler();

        if (ret.skipped) continue;

        res.writeBody(ret.json.toPrettyString(), "application/json");

        break;
    }

    throw new HTTPStatusException(HTTPStatus.notFound);
}
