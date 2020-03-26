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

	@path("/raw/:id/:index")
	public void getRawPasty(string _id, int _index)
	{
		import pastemyst.db : findOneById;
		import pastemyst.data : Paste;
		
		const auto paste = findOneById!Paste(_id);
		enforceHTTP(!paste.isNull, HTTPStatus.notFound, "invalid paste id.");
		enforceHTTP(!(_index + 1 > paste.get().pasties.length || _index < 0), HTTPStatus.notFound, "invalid pasty index.");

		const auto pasty = paste.get().pasties[_index];
		const string pasteTitle = paste.get().title == "" ? "untitled" : paste.get().title;
		const string pastyTitle = pasty.title == "" ? "untitled" : pasty.title;
		const string title = pasteTitle ~ " - " ~ pastyTitle;
		const string rawCode = pasty.code;

		render!("raw.dt", title, rawCode);
    }
}
