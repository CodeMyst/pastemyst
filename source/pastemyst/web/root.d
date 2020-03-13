module pastemyst.web.root;

import vibe.d;

/++
 + web interface for the `/` endpoint.
 +/
public class RootWeb
{
    /++
     + GET /
     +
     + home page
     +/
    @path("/")
    public void getHome()
    {
        import pastemyst.data : expireOptions, languages;

        // todo: this can be moved to the template
		// a separate variable is made for expireOptions only to change its name
		const Json expires = expireOptions;

		render!("home.dt", expires, languages);
    }
}
