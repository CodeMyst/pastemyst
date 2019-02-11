module api;

import vibe.web.common : path, bodyParam, method, queryParam, rootPathFromName;
import vibe.http.common : HTTPMethod;
import vibe.data.json : Json;

/++
    Interface for the REST API
+/
public interface IRestApiInterface
{
    /++
        POST /api/paste
    +/
	@bodyParam ("code", "code")
	@bodyParam ("expiresIn", "expiresIn")
	@bodyParam ("language", "language")
	@method (HTTPMethod.POST)
	@path ("/api/paste")
	public Json postPaste (string code, string expiresIn, string language = "autodetect") @safe;

    /++
        GET /api/paste?id={id}
    +/
	@queryParam ("id", "id")
    @method (HTTPMethod.GET)
	public Json getPaste (string id) @safe;
}

/++
    REST API Implementation
+/
@rootPathFromName
public class RestApiInterface : IRestApiInterface
{
    /++
        POST /api/paste
    +/
	public override Json postPaste (string code, string expiresIn, string language) @trusted
	{
        import pastemyst : createPaste;
        import vibe.data.json : serializeToJson;

		return createPaste (code, expiresIn, language).serializeToJson;
	}

    /++
        GET /api/paste?id={id}
    +/
	public override Json getPaste (string id) @trusted
	{
        import pastemyst : getPaste, PasteMystInfo;
        import vibe.http.common : HTTPStatusException;
        import vibe.data.json : serializeToJson;

		PasteMystInfo info = getPaste (id);
		
		if (info.id is null)
			throw new HTTPStatusException (404);
		
		return info.serializeToJson;
	}
}

// TODO: Re add unit tests
// unittest
// {
//     import vibe.http.common : HTTPMethod;
//     import vibe.http.router : URLRouter;
//     import vibe.http.server : HTTPServerSettings, listenHTTP;
//     import vibe.web.rest : registerRestInterface, RestInterfaceClient;
//     import vibe.data.json : deserializeJson;
//     import pastemyst : initialize, deleteDbTable, PasteMystInfo;

// 	URLRouter router = new URLRouter;
// 	registerRestInterface (router, new RestApiInterface);
// 	auto routes = router.getAllRoutes ();

// 	assert (routes [0].method == HTTPMethod.POST && routes [0].pattern == "/api/paste");
// 	assert (routes [1].method == HTTPMethod.GET && routes [1].pattern == "/:id/paste");

// 	auto settings = new HTTPServerSettings;
// 	settings.port = 5000;
// 	settings.bindAddresses = ["127.0.0.1"];
// 	immutable serverAddr = listenHTTP (settings, router).bindAddresses [0];

// 	auto api = new RestInterfaceClient!IRestApiInterface ("http://" ~ serverAddr.toString);

// 	initialize ();

// 	const PasteMystInfo info1 = deserializeJson!PasteMystInfo (api.postPaste ("void%20main%20()%0A%7B%0A%7D", "never", "d"));
// 	assert (info1.code == "void%20main%20()%0A%7B%0A%7D" && info1.expiresIn == "never" && info1.language == "d");

// 	const PasteMystInfo info2 = deserializeJson!PasteMystInfo (api.getPaste (info1.id));
// 	assert (info2.code == "void%20main%20()%0A%7B%0A%7D" && info2.expiresIn == "never" &&
// 			info2.id == info1.id && info2.createdAt == info1.createdAt && info2.language == "d");

// 	deleteDbTable ();
// }
