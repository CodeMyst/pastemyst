module pastemyst.rest.paste;

import pastemyst.data;
import vibe.d;
import std.typecons;

/++
 + API interface for the `/api/paste` endpoint.
 +/
@path("/api/v2")
public interface IAPIPaste
{
    /++
     + POST /paste
     +
     + Creates a paste.
     +/
    @bodyParam("title", "title")
    @bodyParam("expiresIn", "expiresIn")
    @bodyParam("isPrivate", "isPrivate")
    @bodyParam("pasties", "pasties")
    @bodyParam("isPublic", "isPublic")
    @bodyParam("tags", "tags")
    @headerParam("auth", "Authorization")
    @path("/paste")
    Json post(Pasty[] pasties, string title = "", string expiresIn = "never",
            bool isPrivate = false, string tags = "", bool isPublic = false, string auth = "") @safe;

    /++ 
     + GET /paste/:id
     +
     + Fetches the paste.
     +/
    @headerParam("auth", "Authorization")
    @path("/paste/:id")
    Json get(string _id, string auth = "") @safe;

    /++
     + PATCH /paste/:id
     +
     + updates/edits a paste
     +/
    @bodyParam("title", "title")
    @bodyParam("tags", "tags")
    @headerParam("auth", "Authorization")
    @path("/paste/:id")
    Json patch(string _id, Nullable!string title, Nullable!bool isPrivate, Nullable!bool isPublic,
            Nullable!string tags, Nullable!(Pasty[]) pasties, Nullable!string auth) @safe;

    /++
     + DELETE /paste/:id
     +
     + deletes a paste
     +/
    @headerParam("auth", "Authorization")
    @path("/paste/:id")
    void deletePaste(string _id, Nullable!string auth) @safe;
}

/++ 
 + API for the `/api/paste` endpoint.
 +/
public class APIPaste : IAPIPaste
{
    /++
     + POST /paste
     +
     + Creates a paste.
     +/
    public Json post(Pasty[] pasties, string title = "", string expiresIn = "never",
            bool isPrivate = false, string tags = "", bool isPublic = false, string auth = "") @safe
    {
        import pastemyst.paste : createPaste, tagsStringToArray;
        import pastemyst.db : insert, findOne;

        string ownerId = "";

        if (auth != "")
        {
            auto apiKey = findOne!ApiKey(["key": auth]);

            if (!apiKey.isNull)
            {
                ownerId = apiKey.get().id;
            }
        }

        if (isPublic || isPrivate || tags != "")
        {
            enforceHTTP(ownerId != "", HTTPStatus.forbidden,
                "can't create a paste using account features without providing a valid Authorization header.");
        }

        Paste paste = createPaste(title, expiresIn, pasties, isPrivate, ownerId);

        paste.isPublic = isPublic;
        paste.isPrivate = isPrivate;
        paste.tags = tagsStringToArray(tags);

        if (ownerId != "")
        {
            if (isPrivate)
            {
                enforceHTTP(!isPublic, HTTPStatus.badRequest,
                    "the paste can't be private and shown on the profile");
            }
        }

        insert(paste);

        return serializeToJson(paste);
    }

    /++ 
     + GET /paste/:id
     +
     + Fetches the paste.
     +/
    public Json get(string _id, string auth = "") @safe
    {
        import pastemyst.db : findOneById, tryFindOneById;

        auto res = tryFindOneById!Paste(_id);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        const paste = res.get();

        if (paste.isPrivate)
        {
            enforceHTTP(auth != "", HTTPStatus.notFound);

            string desiredToken = findOneById!ApiKey(paste.ownerId).get().key;

            enforceHTTP(auth == desiredToken, HTTPStatus.notFound);
        }

        return serializeToJson(paste);
    }

    /++
     + PATCH /paste/:id
     +
     + updates/edits a paste
     +/
    public Json patch(string _id, Nullable!string title, Nullable!bool isPrivate, Nullable!bool isPublic,
            Nullable!string tags, Nullable!(Pasty[]) pasties, Nullable!string auth) @safe
    {
        import pastemyst.db : findOneById, update, tryFindOneById;
        import std.datetime : Clock;
        import std.algorithm : canFind, countUntil, remove;
        import std.conv : to;
        import pastemyst.util : generateUniqueEditId, generateDiff, generateUniquePastyId;
        import pastemyst.paste : tagsStringToArray;

        auto res = tryFindOneById!Paste(_id);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        auto paste = res.get();

        enforceHTTP(paste.ownerId != "", HTTPStatus.notFound);

        enforceHTTP(!auth.isNull, HTTPStatus.notFound);

        string desiredToken = findOneById!ApiKey(paste.ownerId).get().key;

        enforceHTTP(auth.get() == desiredToken, HTTPStatus.notFound);

        ulong editId = 0;
        if (paste.edits.length > 0)
        {
            editId = paste.edits[$-1].editId + 1;
        }

        const editedAt = Clock.currTime().toUnixTime();

        if (!title.isNull && title.get() != paste.title)
        {
            Edit edit;
            edit.uniqueId = generateUniqueEditId(paste);
            edit.editId = editId;
            edit.editType = EditType.title;
            edit.edit = paste.title;
            edit.editedAt = editedAt;

            paste.title = title.get();
            paste.edits ~= edit;
        }

        if (!tags.isNull)
        {
            const string[] tagsArr = tagsStringToArray(tags.get());

            if (paste.tags != tagsArr)
            {
                paste.tags = tagsArr.dup;
            }
        }

        if (!isPrivate.isNull)
        {
            paste.isPrivate = isPrivate.get();
        }

        if (!isPublic.isNull)
        {
            paste.isPublic = isPublic.get();
        }

        if (paste.isPrivate)
        {
            enforceHTTP(!paste.isPublic, HTTPStatus.badRequest,
                "paste can't be private and shown on the profile at the same time");
        }

        if (!pasties.isNull)
        {
            foreach (editedPasty; pasties.get())
            {
                enforceHTTP(paste.pasties.canFind!((p) => p.id == editedPasty.id),
                            HTTPStatus.badRequest, "can't edit a pasty that doesn't exist");

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

                    pasty.language = getLanguageName(pasty.language);
                    enforceHTTP(!(pasty.language is null), HTTPStatus.badRequest, "invalid language value.");

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

            foreach (pasty; paste.pasties)
            {
                if (!pasties.get().canFind!((p) => p.id == pasty.id))
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

            foreach (editedPasty; pasties.get())
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
        }

        update!Paste(["_id": _id], paste);

        return serializeToJson(paste);
    }

    /++
     + DELETE /paste/:id
     +
     + deletes a paste
     +/
    void deletePaste(string _id, Nullable!string auth) @safe
    {
        import pastemyst.db : findOneById, removeOneById, tryFindOneById;

        auto res = tryFindOneById!Paste(_id);

        enforceHTTP(!res.isNull, HTTPStatus.notFound);

        auto paste = res.get();

        enforceHTTP(paste.ownerId != "", HTTPStatus.notFound);

        enforceHTTP(!auth.isNull, HTTPStatus.notFound);

        string desiredToken = findOneById!ApiKey(paste.ownerId).get().key;

        enforceHTTP(auth.get() == desiredToken, HTTPStatus.notFound);

        removeOneById!Paste(paste.id);
    }
}
