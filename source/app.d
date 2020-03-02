import vibe.d;

public void main()
{
	import pastemyst.web : WebInterface;
	import pastemyst.rest : APIPaste, APITime, APIData;
	import pastemyst.db : connect;

	URLRouter router = new URLRouter();
	router.get("*", serveStaticFiles("public"));
	router.registerWebInterface(new WebInterface());
	router.registerRestInterface(new APIPaste());
	router.registerRestInterface(new APITime());
	router.registerRestInterface(new APIData());

	HTTPServerSettings serverSettings = new HTTPServerSettings();
	serverSettings.bindAddresses = ["127.0.0.1"];
	serverSettings.port = 5000;

	listenHTTP(serverSettings, router);

	connect();

	runApplication();
}
