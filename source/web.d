module web;

import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.web.common : path, method;
import vibe.http.common : HTTPMethod;

/++
    Interface for the website
+/
public interface IWebInterface
{
    /++
        GET /
    +/
    public void get (HTTPServerRequest req, HTTPServerResponse);

    /++
        GET /api-docs
    +/
	@path ("/api-docs")
    public void getApiDocs (HTTPServerRequest req, HTTPServerResponse);

	/++
		GET /login
	+/
	public void getLogin ();

	/++
		GET /login/github?code=
	+/
	@path ("/login/github")
	public void getGithubCode (HTTPServerRequest req, HTTPServerResponse res);

    /++
        POST /paste
    +/
    public void postPaste (string code, string expiresIn, string language);

    /++
        GET /paste?id={id}
    +/
    public void getPaste (string id, HTTPServerRequest req, HTTPServerResponse res);

	/++
		GET /:id

		This function has to be later than getPaste (string)!
	+/
	@path("/:id")
	@method (HTTPMethod.GET)
	public void getPaste (HTTPServerRequest req, HTTPServerResponse);
}

/++
    Web Interface Implementation
+/
class WebInterface : IWebInterface
{
    /++
        GET /
    +/
	public override void get (HTTPServerRequest req, HTTPServerResponse)
	{
		import vibe.web.web : render;
       
	    const WebInfo webInfo = getWebInfo (req);

		render!("index.dt", webInfo);
	}

    /++
        GET /api-docs
	+/
	@path ("/api-docs")
    public override void getApiDocs (HTTPServerRequest req, HTTPServerResponse)
	{
		import vibe.web.web : render;

        const WebInfo webInfo = getWebInfo (req);

		render!("api-docs.dt", webInfo);
	}

	/++
		GET /login
	+/
	public override void getLogin ()
	{
		import github : authorize;

		authorize ();
	}

	/++
		GET /login/github?code=
	+/
	@path ("/login/github")
	public override void getGithubCode (HTTPServerRequest req, HTTPServerResponse res)
	{
		import github : getAccessToken;
		import vibe.http.common : Cookie;
        import vibe.web.web : redirect;

		const string code = req.query.get ("code");

		const string accessToken = getAccessToken (code);

		Cookie c = new Cookie;
		c.path = "/";
		c.value = accessToken;

		res.cookies ["github"] = c;

		redirect ("/");
	}

    /++
        POST /paste
	+/
    public override void postPaste (string code, string expiresIn, string language)
	{
        import pastemyst : PasteMystInfo, createPaste;
        import vibe.web.web : redirect;

		PasteMystInfo info = createPaste (code, expiresIn, language);

		redirect ("/" ~ info.id);
	}

    /++
        GET /paste?id={id}

		NOTE: This is kept for backwards compatibility, you should get the paste with /:id
	+/
    public override void getPaste (string id, HTTPServerRequest req, HTTPServerResponse)
	{
		import std.uri : decodeComponent;
        import pastemyst : PasteMystInfo, getPaste, expiresInToUnixTime;
        import vibe.http.common : HTTPStatusException;
		import vibe.web.web : render;
        import std.datetime.systime : SysTime;
		import std.datetime.timezone : UTC;

		PasteMystInfo info = getPaste (id);

		if (info.id is null)
			throw new HTTPStatusException (404);

		immutable string createdAt = SysTime.fromUnixTime (info.createdAt, UTC ()).toUTC.toString [0..$-1];
		
		string expiresAt;
		if (info.expiresIn == "never")
		{
			expiresAt = "never";
		}
		else
		{
			expiresAt = SysTime.fromUnixTime (expiresInToUnixTime (info.createdAt, info.expiresIn), UTC ())
						.toUTC.toString [0..$-1];
		}

		immutable string code = decodeComponent (info.code);

		const string language = info.language;

        WebInfo webInfo = getWebInfo (req);

		render!("paste.dt", id, createdAt, code, expiresAt, language, webInfo);
	}

	/++
		GET /:id

		This function has to be later than getPaste (string)!
	+/
	@path("/:id")
	public override void getPaste (HTTPServerRequest req, HTTPServerResponse res)
	{
		string id = req.params ["id"];

		return getPaste (id, req, res);
	}
}

public struct WebInfo
{
    long numberOfPastes;
    bool isLoggedIn;
}

public WebInfo getWebInfo (HTTPServerRequest req)
{
    import github : isLoggedIn;
    import pastemyst : getNumberOfPastes;

    return WebInfo (getNumberOfPastes (), isLoggedIn (req));
}
