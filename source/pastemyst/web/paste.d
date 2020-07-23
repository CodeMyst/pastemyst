module pastemyst.web.paste;

import vibe.d;
import vibe.web.auth;
import pastemyst.data;
import pastemyst.web;

import std.typecons : Nullable;

/++
 + web interface for getting pastes
 +/
@requiresAuth
public class PasteWeb
{
    mixin Auth;

    /++
     + GET /:id
     +
     + gets the paste with the specified id
     +/
    @path("/:id")
    @noAuth
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

        if (paste.isPrivate && (paste.ownerId != session.user.id))
        {
            return;
        }

        const title = paste.title != "" ? paste.title : "(untitled)";

        render!("paste.dt", paste, title, session);
    }

    /++
     + POST /:id/star
     +
     + stars the paste
     +/
    @path("/:id/star")
    @anyAuth
    public void postStar(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById, update;
        import std.algorithm : canFind, remove, countUntil;

        const auto res = findOneById!Paste(_id);

        if (res.isNull)
        {
            return;
        }

        const Paste paste = res.get();

        UserSession session = req.session.get!UserSession("user");

        if (paste.isPrivate && (paste.ownerId != session.user.id))
        {
            return;
        }

        auto user = findOneById!User(session.user.id).get();

        int incAmnt = 1;

        if (user.stars.canFind(paste.id))
        {
            incAmnt = -1;
            user.stars = user.stars.remove(user.stars.countUntil(paste.id));
        }
        else
        {
            user.stars ~= paste.id;
        }

        update!User(["_id": user.id], ["$set": ["stars": user.stars]]);
        update!Paste(["_id": _id], ["$inc": ["stars": incAmnt]]);

        redirect("/" ~ _id);
    }

    /++
     + POST /:id/togglePrivate
     +
     + toggles whether the paste is private
     +/
    @path("/:id/togglePrivate")
    @noAuth
    public void postTogglePrivate(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById, update;

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

            if (paste.ownerId != "" && paste.ownerId == session.user.id && !paste.isPublic)
            {
                update!Paste(["_id": _id], ["$set": ["isPrivate": !paste.isPrivate]]);
                redirect("/" ~ _id);
                return;
            }
        }

        throw new HTTPStatusException(HTTPStatus.forbidden);
    }

    /++
     + POST /:id/togglePublicOnProfile
     +
     + toggles whether the paste is public on the user's profile
     +/
    @path("/:id/togglePublicOnProfile")
    @noAuth
    public void postTogglePublicOnProfile(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById, update;

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

            if (paste.ownerId != "" && paste.ownerId == session.user.id && !paste.isPrivate)
            {
                update!Paste(["_id": _id], ["$set": ["isPublic": !paste.isPublic]]);
                redirect("/" ~ _id);
                return;
            }
        }

        throw new HTTPStatusException(HTTPStatus.forbidden);
    }

    /++
     + POST /:id/anon
     +
     + makes the paste anonymous
     +/
    @path("/:id/anon")
    @noAuth
    public void postPasteAnon(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById, update;

        auto res = findOneById!Paste(_id);

        if (res.isNull)
        {
            return;
        }

        auto paste = res.get();

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");

            if (paste.ownerId != "" && paste.ownerId == session.user.id)
            {
                paste.ownerId = "";
                paste.isPrivate = false;
                paste.isPublic = false;
                paste.tags.length = 0;
                paste.edits.length = 0;
                update!Paste(["_id": _id], paste);
                redirect("/" ~ _id);
                return;
            }
        }

        throw new HTTPStatusException(HTTPStatus.forbidden);
    }

    /++
     + POST /:id/delete
     +
     + deletes a user's paste
     +/
    @path("/:id/delete")
    @noAuth
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
    @noAuth
    public void postPaste(string title, string tags, string expiresIn, bool isPrivate, bool isPublic,
            bool isAnonymous, string pasties, HTTPServerRequest req)
    {
        import pastemyst.paste : createPaste, tagsStringToArray;
        import pastemyst.db : insert;

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
                throw new HTTPStatusException(HTTPStatus.forbidden,
                        "you cant create a profile public paste if you are not logged in.");
            }
        }

        if (session.loggedIn)
        {
            if (isAnonymous)
            {
                enforceHTTP(!isPrivate && !isPublic,
                        HTTPStatus.badRequest,
                        "the paste cant be private or shown on the profile if its anonymous");

                paste.ownerId = "";
            }

            if (isPrivate)
            {
                enforceHTTP(!isAnonymous && !isPublic,
                        HTTPStatus.badRequest,
                        "the paste cant be anonymous or shown on the profile if its private");
            }
        }

        if (tags != "")
        {
            enforceHTTP(session.loggedIn, HTTPStatus.forbidden, "you cant tag pastes if you are not logged in.");

            paste.tags = tagsStringToArray(tags);
        }

        insert(paste);

        redirect("/" ~ paste.id);
    }

    @path("/raw/:pasteId/:pastyId")
    @noAuth
    public void getRawPasty(string _pasteId, string _pastyId)
    {
        getRawPasty(_pasteId, _pastyId, -1);
    }

    /++
     + GET /raw/:id/index
     +
     + gets the raw data of the pasty
     +/
    @path("/raw/:pasteId/:pastyId/:editId")
    @noAuth
    public void getRawPasty(string _pasteId, string _pastyId, long _editId)
    {
        import pastemyst.db : findOneById;
        import pastemyst.data : Paste;
        import std.algorithm : canFind, find;

        const auto res = findOneById!Paste(_pasteId);

        if (res.isNull())
        {
            return;
        }

        if (res.get().isPrivate)
        {
            return;
        }

        if (_editId < -1)
        {
            return;
        }

        Paste paste;

        if (_editId == -1)
        {
            paste = cast(Paste) res.get();
        }
        else
        {
            paste = pasteRevision(_pasteId, _editId);
        }

        if (!paste.pasties.canFind!((p) => p.id == _pastyId))
        {
            return;
        }

        const Pasty pasty = paste.pasties.find!((p) => p.id == _pastyId)[0];

        const string pasteTitle = paste.title == "" ? "untitled" : paste.title;
        const string pastyTitle = pasty.title == "" ? "untitled" : pasty.title;
        const string title = pasteTitle ~ " - " ~ pastyTitle;
        const string rawCode = pasty.code;

        render!("raw.dt", title, rawCode);
    }

    /++
     + GET /:id/edit
     +
     + page for editing the paste
     +/
    @path("/:id/edit")
    @anyAuth
    public void getPasteEdit(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        UserSession session = req.session.get!UserSession("user");
        auto res = findOneById!Paste(_id);

        if (res.isNull())
        {
            return;
        }

        const paste = res.get();

        if (paste.ownerId != session.user.id)
        {
            return;
        }

        render!("editPaste.dt", session, paste);
    }

    /++
     + POST /:id/edit
     +
     + edit a paste
     +/
    @path("/:id/edit")
    @method(HTTPMethod.POST)
    @anyAuth
    public void postPasteEdit(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById, update;
        import std.array : split, join;
        import std.conv : to;
        import std.datetime : Clock;
        import pastemyst.util : generateDiff;
        import std.algorithm : canFind, find, countUntil, remove;
        import pastemyst.paste : tagsStringToArray;

        auto res = findOneById!Paste(_id);

        if (res.isNull())
        {
            return;
        }

        auto session = req.session.get!UserSession("user");

        Paste paste = res.get();

        if (paste.ownerId != session.user.id)
        {
            return;
        }

        Paste editedPaste;
        editedPaste.title = req.form["title"];

        string tagsString = req.form["tags"];
        editedPaste.tags = tagsStringToArray(tagsString);

        int i = 0;
        while(true)
        {
            Pasty pasty;
            if (("title-" ~ i.to!string()) !in req.form)
            {
                break;
            }

            pasty.id = req.form["id-" ~ i.to!string()];
            pasty.title = req.form["title-" ~ i.to!string()];
            pasty.language = req.form["language-" ~ i.to!string()].split(",")[0];
            pasty.code = req.form["code-" ~ i.to!string()];
            editedPaste.pasties ~= pasty;

            i++;
        }

        ulong editId = 0;
        if (paste.edits.length > 0)
        {
            editId = paste.edits[$-1].editId + 1;
        }
        const editedAt = Clock.currTime().toUnixTime();

        if (paste.title != editedPaste.title)
        {
            Edit edit;
            edit.uniqueId = generateUniqueEditId(paste);
            edit.editId = editId;
            edit.editType = EditType.title;
            edit.edit = paste.title;
            edit.editedAt = editedAt;

            paste.title = editedPaste.title;
            paste.edits ~= edit;
        }

        if (paste.tags != editedPaste.tags)
        {
            paste.tags = editedPaste.tags;
        }

        foreach (editedPasty; editedPaste.pasties)
        {
            if (paste.pasties.canFind!((p) => p.id == editedPasty.id))
            {
                ulong pastyIndex = paste.pasties.countUntil!((p) => p.id == editedPasty.id);
                Pasty pasty = paste.pasties[pastyIndex];

                if (pasty.title != editedPasty.title)
                {
                    Edit edit;
                    edit.uniqueId = generateUniqueEditId(paste);
                    edit.editId = editId;
                    edit.editType = EditType.pastyTitle;
                    edit.edit = pasty.title;
                    edit.metadata ~= pasty.id.to!string();
                    edit.editedAt = editedAt;

                    pasty.title = editedPasty.title;
                    paste.pasties[pastyIndex] = pasty;
                    paste.edits ~= edit;
                }

                if (pasty.language != editedPasty.language)
                {
                    enforceHTTP(editedPasty.language.toLower() != "auotedect",
                                HTTPStatus.badRequest,
                                "can't edit a pasty to have an autodetect language.");

                    Edit edit;
                    edit.uniqueId = generateUniqueEditId(paste);
                    edit.editId = editId;
                    edit.editType = EditType.pastyLanguage;
                    edit.edit = pasty.language;
                    edit.metadata ~= pasty.id.to!string();
                    edit.editedAt = editedAt;

                    pasty.language = editedPasty.language;
                    paste.pasties[pastyIndex] = pasty;
                    paste.edits ~= edit;
                }

                if (pasty.code != editedPasty.code)
                {
                    Edit edit;
                    edit.uniqueId = generateUniqueEditId(paste);
                    edit.editId = editId;
                    edit.editType = EditType.pastyContent;
                    edit.metadata ~= pasty.id.to!string();
                    edit.editedAt = editedAt;

                    string diffId = paste.id ~ "-" ~ edit.uniqueId;

                    edit.edit = generateDiff(diffId, pasty.code, editedPasty.code);

                    pasty.code = editedPasty.code;
                    paste.pasties[pastyIndex] = pasty;
                    paste.edits ~= edit;
                }
            }
        }

        foreach (pasty; paste.pasties)
        {
            if (!editedPaste.pasties.canFind!((p) => p.id == pasty.id))
            {
                Edit edit;
                edit.uniqueId = generateUniqueEditId(paste);
                edit.editId = editId;
                edit.editType = EditType.pastyRemoved;
                edit.edit = pasty.code;
                edit.metadata ~= pasty.id;
                edit.metadata ~= pasty.title;
                edit.metadata ~= pasty.language;
                edit.editedAt = editedAt;

                paste.pasties = paste.pasties.remove!((p) => p.id == pasty.id);
                paste.edits ~= edit;
            }
        }

        foreach (editedPasty; editedPaste.pasties)
        {
            if (editedPasty.id == "")
            {
                Edit edit;
                edit.uniqueId = generateUniqueEditId(paste);
                edit.editId = editId;
                edit.editType = EditType.pastyAdded;
                edit.edit = editedPasty.code;
                edit.editedAt = editedAt;

                editedPasty.id = generateUniquePastyId(paste);
                paste.pasties ~= editedPasty;

                edit.metadata ~= editedPasty.id;
                edit.metadata ~= editedPasty.title;
                edit.metadata ~= editedPasty.language;

                paste.edits ~= edit;
            }
        }

        update!Paste(["_id": _id], paste);

        redirect("/" ~ _id);
    }

    private string generateUniqueEditId(Paste paste)
    {
        import pastemyst.encoding : randomBase36Id;
        import std.algorithm : canFind;

        string id;

        do
        {
            id = randomBase36Id();
        } while(paste.edits.canFind!((e) => e.uniqueId == id));

        return id;
    }

    /++
     + GET /:id/history
     +
     + get all the edits of a paste
     +/
    @path("/:id/history")
    @noAuth
    public void getPasteHistory(string _id, HTTPServerRequest req)
    {
        import pastemyst.db : findOneById;

        auto res = findOneById!Paste(_id);

        if (res.isNull())
        {
            return;
        }

        Paste paste = res.get();
        // TODO: this line is here because otherwise d-scanner
        // complains that paste isn't changed anywhere and it can be
        // declared const
        paste.title = paste.title;

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");
        }

        if (paste.isPrivate && paste.ownerId != session.user.id)
        {
            return;
        }

        render!("history.dt", session, paste);
    }

    /++
     + GET /:pasteId/history/:editId
     +
     + gets the paste at the specific edit
     +/
    @path("/:pasteId/history/:editId")
    @noAuth
    public void getPasteRevision(string _pasteId, ulong _editId, HTTPServerRequest req)
    {
        const Paste paste = pasteRevision(_pasteId, _editId);

        if (paste == Paste.init)
        {
            return;
        }

        UserSession session = UserSession.init;

        if (req.session && req.session.isKeySet("user"))
        {
            session = req.session.get!UserSession("user");
        }

        if (paste.isPrivate && paste.ownerId != session.user.id)
        {
            return;
        }

        const bool previousRevision = true;
        const ulong currentEditId = _editId;
        render!("paste.dt", session, paste, previousRevision, currentEditId);
    }

    private Paste pasteRevision(string _pasteId, ulong _editId)
    {
        import pastemyst.db : findOneById;
        import std.algorithm : reverse, countUntil, remove;
        import std.stdio : writeln;
        import pastemyst.util : patchDiff;

        auto res = findOneById!Paste(_pasteId);

        if (res.isNull)
        {
            return Paste.init;
        }

        Paste paste = res.get();

        // if there are no edits, and the user is looking for the first edit
        // redirect to the current version
        if (_editId == 0 && paste.edits.length == 0)
        {
            return paste;
        }
        // check if the edit id is greater then the length of edits by one
        // this means the user is looking for the current version
        // this allows getting a permlink to the current version, even if more edits
        // will be made in the future
        else if (_editId > 0 && _editId == paste.edits.length)
        {
            return paste;
        }

        // check if edit id is invalid
        if (_editId > 0 && _editId > paste.edits.length)
        {
            return Paste.init;
        }

        foreach (edit; paste.edits.reverse())
        {
            final switch (edit.editType)
            {
                case EditType.title:
                {
                    paste.title = edit.edit;
                } break;

                case EditType.pastyTitle:
                {
                    ulong pastyIndex = paste.pasties.countUntil!((p) => p.id == edit.metadata[0]);
                    paste.pasties[pastyIndex].title = edit.edit;
                } break;

                case EditType.pastyLanguage:
                {
                    ulong pastyIndex = paste.pasties.countUntil!((p) => p.id == edit.metadata[0]);
                    paste.pasties[pastyIndex].language = edit.edit;
                } break;

                case EditType.pastyContent:
                {
                    ulong pastyIndex = paste.pasties.countUntil!((p) => p.id == edit.metadata[0]);
                    string diffId = _pasteId ~ "-" ~ edit.uniqueId;
                    paste.pasties[pastyIndex].code = patchDiff(diffId, paste.pasties[pastyIndex].code, edit.edit);
                } break;

                case EditType.pastyAdded:
                {
                    paste.pasties = paste.pasties.remove!((p) => p.id == edit.metadata[0]);
                } break;

                case EditType.pastyRemoved:
                {
                    // TODO: this adds to the end of the list, while the paste might've been
                    // removed from the middle of the list
                    Pasty p;
                    p.id = edit.metadata[0];
                    p.title = edit.metadata[1];
                    p.language = edit.metadata[2];
                    p.code = edit.edit;
                    paste.pasties ~= p;
                } break;
            }

            if (edit.editId == _editId)
            {
                break;
            }
        }

        return paste;
    }
}
