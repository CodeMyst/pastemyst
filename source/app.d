import vibe.d;

public void main ()
{
	URLRouter router = new URLRouter ();
	router.registerWebInterface (new WebInterface ());

	HTTPServerSettings serverSettings = new HTTPServerSettings ();
	serverSettings.bindAddresses = ["127.0.0.1"];
	serverSettings.port = 5000;

	listenHTTP (serverSettings, router);

	runApplication ();
}

public class WebInterface
{
	public void index ()
	{
		render!("index.dt");
	}
}
