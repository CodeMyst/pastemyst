module api.paste_controller;

import vibe.d;
import model;
import services;

@path("api/v3/paste")
public interface IPasteController
{
    @path(":id")
    Paste get(string _id) @safe;

    @bodyParam("skeleton")
    Paste post(PasteSkeleton skeleton) @safe;
}

public class PasteController : IPasteController
{
    private PasteService pastes;

    public this(PasteService pastes)
    {
        this.pastes = pastes;
    }

    public override Paste get(string _id)
    {
        auto p = pastes.get(_id);

        enforceHTTP(p !is null, HTTPStatus.notFound);

        return p;
    }

    public override Paste post(PasteSkeleton skeleton)
    {
        try
        {
            return pastes.create(skeleton);
        }
        catch (Exception e)
        {
            throw new HTTPStatusException(HTTPStatus.badRequest, e.msg);
        }
    }
}
