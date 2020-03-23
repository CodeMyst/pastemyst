module pastemyst.web.paste;

import vibe.d;
import pastemyst.data;

/++
 + web interface for getting pastes
 +/
public class PasteWeb
{
    /// user session
    public SessionVar!(UserSession, "user") userSession;

    /++
     + GET /:id
     +
     + gets the paste with the specified id
     +/
    @path("/:id")
    public void getPaste(string _id)
    {
        import pastemyst.db : findOneById;
		import std.conv : to;
 
		const auto res = findOneById!Paste(_id);
 
		if (res.isNull)
		{
			return;
		}
 
		const Paste paste = res.get();
 
		render!("paste.dt", paste, userSession);
    }
}
