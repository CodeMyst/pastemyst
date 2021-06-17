import vibe.d;

import pastemyst.request.router;

import pastemyst.api.data;

public void main()
{
    auto serverSettings = new HTTPServerSettings();
    serverSettings.bindAddresses = ["127.0.0.1"];
    serverSettings.port = 5005;

    registerRoutes(TestApi());

    listenHTTP(serverSettings, &handleRequests);
    runApplication();
}

private void handleRequests(HTTPServerRequest req, HTTPServerResponse res)
{
    auto route = matchRoute(req.requestPath.toString());

    if (route.isNull)
    {
        throw new HTTPStatusException(HTTPStatus.notFound);
    }

    auto ret = route.get().handler();

    res.writeBody(ret.toPrettyString(), "application/json");
}
