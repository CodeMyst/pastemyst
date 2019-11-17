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
		render!("index.dt");
	}
}
