module api.data_controller;

import vibe.d;
import model;
import services;

@path("api/v3/data")
public interface IDataController
{
    @path("langs")
    const(Language[string]) getLanguages() @safe;   
}

public class DataController : IDataController
{
    private const LangService langs;

    public this(LangService langs)
    {
        this.langs = langs;
    }

    public override const(Language[string]) getLanguages()
    {
        return langs.getLanguages();
    }
}
