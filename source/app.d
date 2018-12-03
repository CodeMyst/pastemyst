import vibe.vibe;

/++
	Displays the error page.
+/
void showError (HTTPServerRequest req, HTTPServerResponse res, HTTPServerErrorInfo error)
{
	import pastemyst : getNumberOfPastes;

	// String with debug info
	string errorDebug = "";
	debug errorDebug = error.debugMessage;
	const long numberOfPastes = getNumberOfPastes ();
	res.render!("error.dt", req, error, errorDebug, numberOfPastes);
}

void main ()
{
	import pastemyst : WebInterface, RestApiInterface, initialize, deleteExpiredPasteMysts;

	auto router = new URLRouter;
	router.registerWebInterface (new WebInterface);
	router.registerRestInterface (new RestApiInterface);
	router.get ("*", serveStaticFiles ("public"));

	auto settings = new HTTPServerSettings;
	settings.bindAddresses = ["127.0.0.1", "::1"];
	settings.port = 5000;
	settings.errorPageHandler = toDelegate (&showError);

	initialize ();

	setTimer (10.minutes, toDelegate (&deleteExpiredPasteMysts), true);

	listenHTTP (settings, router);
	runApplication ();
}
