import vibe.vibe;

void main ()
{
	auto settings = new HTTPServerSettings;
	settings.port = 5000;
	settings.bindAddresses = ["::1", "127.0.0.1"];
	listenHTTP (settings, &hello);

	logInfo ("Please open http://127.0.0.1:5000/ in your browser.");
	runApplication();
}

void hello (HTTPServerRequest req, HTTPServerResponse res)
{
	res.writeBody ("Hello, World!");
}
