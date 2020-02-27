module pastemyst.web;

import vibe.d;

/++ 
 + Web interface
 +/
public class WebInterface
{
	/++ 
	 + index
	 +/
	@path("/")
	public void getHome()
	{
		import pastemyst.data : expireOptions, languages;

		// a separate variable is made for expireOptions only to change its name
		const Json expires = expireOptions;

		render!("home.dt", expires, languages);
	}
}