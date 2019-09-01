module pastemyst.web.raw;

import vibe.vibe;

/++
 + Web interface for retrieving raw pastes
 +/
public interface IRawWeb
{
    /++
     + `GET /:id`
     +
     + Returns the raw paste contents.
     +/
    @path ("/:id/:pastyIndex/raw")
    void get (string _id, ulong _pastyIndex, HTTPServerResponse res) @safe;
}

/++
 + Web interface for retrieving raw pastes
 +/
public class RawWeb : IRawWeb
{
    /++
     + `GET /:id`
     +
     + Returns the raw paste contents.
     +/
    @path ("/:id/:pastyIndex/raw")
    public void get (string _id, ulong _pastyIndex, HTTPServerResponse res) @safe
    {
        import std.typecons : Nullable;
        import pastemyst.data : Paste;
        import pastemyst.db : findOneByIdMongo;
        import vibe.core.log : logInfo;

        const Nullable!Paste result = findOneByIdMongo!Paste (_id);

        if (result.isNull)
        {
            throw new HTTPStatusException (HTTPStatus.notFound);
        }
     
        const (Paste) paste = result.get ();

        if (_pastyIndex > paste.pasties.length)
        {
            throw new HTTPStatusException (HTTPStatus.notFound, "Invalid pasty index.");
        }

        res.writeBody (paste.pasties [_pastyIndex].code, null);
    }
}
