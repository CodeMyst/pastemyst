import vibe.d;

unittest
{
    import web : WebInterface;
    import std.conv : to;

    URLRouter router = new URLRouter ();
    router.registerWebInterface (new WebInterface ());

    HTTPServerSettings serverSettings = new HTTPServerSettings ();
    serverSettings.bindAddresses = ["127.0.0.1"];
    serverSettings.port = 5000;

    listenHTTP (serverSettings, router);

    requestHTTP ("http://" ~ serverSettings.bindAddresses [0] ~ ":" ~ serverSettings.port.to!string (),
    (scope req)
    {
        req.method = HTTPMethod.GET;
    },
    (scope res)
    {
        assert (res.bodyReader.readAllUTF8 () == `<!DOCTYPE html>
<html lang="en">
	<head>
		<title>pastemyst</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
	</head>
	<body>
		<p>hello</p>
	</body>
</html>`);
    });
}
