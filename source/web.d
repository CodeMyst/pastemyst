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
	public void index ()
	{
		import data.file : expireOptions;

		const Json expires = expireOptions;

		render!("index.dt", expires);
	}
}
