import vibe.vibe;

public void main ()
{
    import pastemyst.rest : APIRoot;
    import vibe.core.log : setLogLevel, LogLevel;
    import vibe.web.common : MethodStyle;

    // setLogLevel (LogLevel.verbose4);

    URLRouter router = new URLRouter ();
    router.registerRestInterface (new APIRoot (), MethodStyle.camelCase);

	auto settings = new HTTPServerSettings;
	settings.port = 5000;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	listenHTTP (settings, router);

	runApplication ();
}
