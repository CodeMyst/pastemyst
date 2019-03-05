import vibe.vibe;

public void main ()
{
    import pastemyst.rest : APIRoot;

    URLRouter router = new URLRouter ();
    router.registerRestInterface (new APIRoot ());

	auto settings = new HTTPServerSettings;
	settings.port = 5000;
	settings.bindAddresses = ["::1", "127.0.0.1"];

	listenHTTP (settings, router);

	runApplication ();
}
