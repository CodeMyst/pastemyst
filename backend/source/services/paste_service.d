module services.paste_service;

import std.datetime;
import std.typecons;
import vibe.d;
import model;
import services;
import utils;

@safe:

public class PasteService
{
    private const LangService langs;
    private const MongoDBService db;

    private MongoCollection pastes;

    public this(LangService langs, MongoDBService db)
    {
        this.langs = langs;
        this.db = db;

        this.pastes = db.getCollection!Paste();
    }

    public Paste get(string id)
    {
        // TODO: check if current time > expiration time just in case
        return pastes.findOne!Paste(["_id": id]);
    }

    public bool exists(string id)
    {
        return get(id) !is null;
    }

    public Paste create(PasteSkeleton skeleton)
    {
        if (skeleton.isShowOnProfile || skeleton.isPrivate || skeleton.tags.length != 0)
        {
            throw new Exception("account pastes not yet implemented.");
        }

        if (skeleton.pasties.length == 0)
        {
            throw new Exception("pasties array has to have at least one pasty.");
        }

        foreach (pasty; skeleton.pasties)
        {
            string langName = langs.getLanguage(pasty.language);

            if (langName is null) throw new Exception("invalid pasty language: " ~ pasty.language);

            pasty.language = langName;
        }

        DateTime createdAt = cast(DateTime) Clock.currTime(UTC());
        Nullable!DateTime deletesAt = getDeletionTime(createdAt, skeleton.expiresIn);

        // TODO: user pastes
        // TODO: encrypted pastes
        // TODO: sanitize titles

        auto res = new Paste();
        res.id = randomPasteId();
        res.createdAt = createdAt;
        res.expiresIn = skeleton.expiresIn;
        res.deletesAt = deletesAt;
        res.title = skeleton.title;
        res.ownerId = "";
        res.isPrivate = false;
        res.isShowOnProfile = false;
        res.isEncrypted = false;

        foreach (pasty; skeleton.pasties)
        {
            pasty.id = randomPastyId(res);

            // TODO: autodetect

            pasty.content = pasty.content.replace("\r\n", "\n");
        }

        res.pasties = skeleton.pasties;

        pastes.insert(res);

        return res;
    }

    private string randomPasteId()
    {
        return randomIdPred(id => exists(id));
    }

    private string randomPastyId(Paste p)
    {
        import std.algorithm : canFind;

        if (p.pasties.length == 0) return randomId();

        return randomIdPred(id => p.pasties.canFind!(pasty => pasty.id == id));
    }
}
