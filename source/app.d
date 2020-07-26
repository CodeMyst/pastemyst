import vibe.d;

/++
 + Renders an error page, everytime an error occured
 +/
void displayError(HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
    import pastemyst.data : UserSession;

    string errorDebug = "";
    debug errorDebug = error.debugMessage;

    UserSession session = UserSession.init;

    if (req.session)
    {
        session = req.session.get!UserSession("user");
    }
    
    import std.stdio : writeln;

    if (req.requestPath.startsWith(InetPath("/api")))
    {
        res.contentType = "application/json";
        res.writeBody(`{"statusMessage": "` ~ error.message ~ `"}`);
        return;
    }

    res.render!("error.dt", error, errorDebug, session);
}

public void main()
{
	import pastemyst.web : RootWeb, PasteWeb, LoginWeb, UserWeb, UsersWeb, ApiDocsWeb;
	import pastemyst.rest : APIPaste, APITime, APIData, APIUser, APIV1Paste;
	import pastemyst.db : connect;
	import pastemyst.paste : deleteExpiredPastes;

	URLRouter router = new URLRouter();

	router.registerRestInterface(new APIPaste());
	router.registerRestInterface(new APIUser());
	router.registerRestInterface(new APITime());
	router.registerRestInterface(new APIData());
	router.registerRestInterface(new APIV1Paste());

	router.registerWebInterface(new RootWeb());
	router.registerWebInterface(new ApiDocsWeb());
	router.registerWebInterface(new LoginWeb());
	router.registerWebInterface(new UserWeb());
	router.registerWebInterface(new UsersWeb());
	router.registerWebInterface(new PasteWeb());

        auto fsettings = new HTTPFileServerSettings();
        fsettings.serverPathPrefix = "/static";

	router.get("/static/*", serveStaticFiles("public/", fsettings));

	HTTPServerSettings serverSettings = new HTTPServerSettings();
	serverSettings.bindAddresses = ["127.0.0.1"];
	serverSettings.port = 5000;
        serverSettings.sessionStore = new MemorySessionStore();
	serverSettings.errorPageHandler = toDelegate(&displayError);

	connect();

	setTimer(15.seconds, toDelegate(&deleteExpiredPastes), true);

	listenHTTP(serverSettings, router);

	runApplication();
}
