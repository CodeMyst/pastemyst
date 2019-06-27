import vibe.vibe;

public void main ()
{
    import pastemyst.rest : APIRoot, APIPaste;
    import pastemyst.web : RawWeb;
    import pastemyst.auth : AuthGitHubWeb, AuthGitHubAPI;
    import pastemyst.db : connectMongoDb, connectRedisDb;
    import vibe.core.log : setLogLevel, LogLevel;
    import vibe.web.common : MethodStyle;

    // setLogLevel (LogLevel.verbose4);

    URLRouter router = new URLRouter ();
    
    router.registerRestInterface (new APIRoot (), MethodStyle.camelCase);
    router.registerRestInterface (new APIPaste (), MethodStyle.camelCase);
    router.registerRestInterface (new AuthGitHubAPI (), MethodStyle.camelCase);

    router.registerWebInterface (new AuthGitHubWeb ());
    router.registerWebInterface (new RawWeb ());

	auto settings = new HTTPServerSettings;
	settings.port = 5000;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	listenHTTP (settings, router);

    connectMongoDb ("127.0.0.1", "pastemyst");
    connectRedisDb ("127.0.0.1");

	runApplication ();
}
