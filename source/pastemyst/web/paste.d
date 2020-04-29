module pastemyst.web.paste;

import vibe.d;
import pastemyst.data;
import pastemyst.web;

import std.typecons : Nullable;

/++
 + web interface for getting pastes
 +/
public class PasteWeb
{
    /++
     + GET /:id
     +
     + gets the paste with the specified id
     +/
    @path("/:id")
    public void getPaste(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;
		import std.conv : to;
 
		const auto res = findOneById!Paste(_id);
 
		if (res.isNull)
		{
			return;
		}
 
		const Paste paste = res.get();
 
        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");    
        }

		render!("paste.dt", paste, session);
    }

    /++
     + POST /:id/delete
     +
     + deletes a user's paste
     +/
    @path("/:id/delete")
    public void postPasteDelete(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById, removeOneById;

        const auto res = findOneById!Paste(_id);

        if (res.isNull)
        {
            return;
        }

        const Paste paste = res.get();

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");

            if (paste.ownerId != "" && paste.ownerId == session.user.id)
            {
                removeOneById!Paste(_id);
                redirect("/user/profile");
                return;
            }
        }

        throw new HTTPStatusException(HTTPStatus.forbidden);
    }

    /++
     + POST /paste
     +
     + creates a paste
     +/
    public void postPaste(string title, string expiresIn, bool isPrivate, bool isPublic, string pasties, HTTPServerRequest req)
    {
        import pastemyst.paste : createPaste;
        import pastemyst.db : insert;

        // TODO: private pastes

        string ownerId = "";

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");

            if (session.loggedIn)
            {
                ownerId = session.user.id;
            }
        }

        Paste paste = createPaste(title, expiresIn, deserializeJson!(Pasty[])(pasties), isPrivate, ownerId);

        if (isPublic)
        {
            if (session.loggedIn)
            {
                paste.isPublic = isPublic;
            }
            else
            {
                throw new HTTPStatusException(HTTPStatus.forbidden, "you cant create a profile public paste if you are not logged in.");
            }
        }

        insert(paste);

        redirect("/" ~ paste.id);
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
