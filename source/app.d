import vibe.vibe;

/++
	Displays the error page.
+/
void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	import pastemyst : getNumberOfPastes;
	import web : WebInfo, getWebInfo;

	// String with debug info
	string errorDebug = "";
	debug errorDebug = error.debugMessage;

	WebInfo webInfo = getWebInfo (req);

	res.render!("error.dt", req, error, errorDebug, webInfo);
}

void main ()
{
	import pastemyst : initialize, deleteExpiredPasteMysts;
	import api : RestApiInterface;
	import web : WebInterface;
	import profile : ProfileInterface;
	// import vibe.core.log : setLogLevel, LogLevel;

	// setLogLevel (LogLevel.verbose2);

	auto router = new URLRouter;
	router.get ("*", serveStaticFiles ("public"));
	router.registerWebInterface (new ProfileInterface);
	router.registerWebInterface (new WebInterface);
	router.registerRestInterface (new RestApiInterface);

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["127.0.0.1"];
	settings.port = 5000;
	settings.errorPageHandler = toDelegate (&showError);

	initialize ();

	setTimer (10.minutes, toDelegate (&deleteExpiredPasteMysts), true);

	listenHTTP (settings, router);
	runApplication ();
}
