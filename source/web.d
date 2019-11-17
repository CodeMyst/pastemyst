module web;

import vibe.d;

public class WebInterface
{
	public void index ()
	{
		render!("index.dt");
	}
}
