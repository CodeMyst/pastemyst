import vibe.d;

public void main()
{
	import pastemyst.web : RootWeb, PasteWeb, LoginWeb, UserWeb;
	import pastemyst.rest : APIPaste, APITime, APIData;
	import pastemyst.db : connect;

	URLRouter router = new URLRouter();
	router.get("*", serveStaticFiles("public"));
	router.registerWebInterface(new RootWeb());
	router.registerWebInterface(new LoginWeb());
	router.registerWebInterface(new UserWeb());
	router.registerWebInterface(new PasteWeb());
	router.registerRestInterface(new APIPaste());
	router.registerRestInterface(new APITime());
	router.registerRestInterface(new APIData());

	HTTPServerSettings serverSettings = new HTTPServerSettings();
	serverSettings.bindAddresses = ["127.0.0.1"];
	serverSettings.port = 5000;
    serverSettings.sessionStore = new MemorySessionStore();

	listenHTTP(serverSettings, router);

	connect();

	runApplication();
}
