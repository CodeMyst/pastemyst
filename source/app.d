import vibe.d;

/++
 + Renders an error page, everytime an error occured
 +/
void displayError(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
    import pastemyst.data : UserSession;

	string errorDebug = "";
	debug errorDebug = error.debugMessage;

    UserSession userSession = UserSession.init;

    if (req.session)
    {
        userSession = req.session.get!UserSession("user");
    }
	
	res.render!("error.dt", error, errorDebug, userSession);
}

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
	serverSettings.errorPageHandler = toDelegate(&displayError);

	listenHTTP(serverSettings, router);

	connect();

	runApplication();
}
