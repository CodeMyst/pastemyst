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

	/++
	 + paste
	 +/
	@path("/:id")
	public void getPaste(string _id)
	{
		import pastemyst.db : findOneById;
		import pastemyst.data : Paste;
		import std.conv : to;
 
		const auto res = findOneById!Paste(_id);
 
		if (res.isNull)
		{
			return;
		}
 
		const Paste paste = res.get();
 
		render!("paste.dt", paste);
	}
}
