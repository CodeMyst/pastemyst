module web;

import vibe.d;

/++ 
 + Web interface
 +/
public class WebInterface
{
	/++ 
	 + index
	 +/
	public void index()
	{
		import data.file : expireOptions, languages;

		// a separate variable is made for expireOptions only to change its name
		const Json expires = expireOptions;

		render!("index.dt", expires, languages);
	}
}
