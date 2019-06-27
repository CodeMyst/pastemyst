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
    @path ("/:id/raw")
    void get (string _id, HTTPServerResponse res) @safe;
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
    @path ("/:id/raw")
    public void get (string _id, HTTPServerResponse res) @safe
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
        else
        {
            res.writeBody (result.get ().code, null);
        }
    }
}
