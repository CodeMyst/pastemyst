module services.lang_service;

import dyaml;
import yamlserialized;
import model;

@safe:

public class LangService
{
    private Language[string] langs;

    public this()
    {
        Node langsYml = Loader.fromFile("data/languages.yml").load();
        langsYml.deserializeInto(langs);
    }

    public const(Language[string]) getLanguages() const
    {
        return langs;
    }

    /**
     * Finds the language based on the provided name, alias or extension.
     *
     * Returns: The proper language name. Returns null if the language isn't found.
     */
    public string getLanguage(string lang) const
    {
        import std.string : toLower;
        import std.algorithm : canFind;

        string resAlias = null;
        string resExtension = null;

        // if found a match by name just return it

        // if found an alias or extension match just keep looping
        // in case another iteration finds a name match

        foreach (key, value; langs)
        {
            // by name
            if (key.toLower() == lang.toLower()) return key;   

            // by alias
            if (value.aliases.length > 0)
            {
                if (value.aliases.canFind!(a => a.toLower() == lang.toLower()))
                {
                    resAlias = key;
                }
            }

            // by extension
            if (value.extensions.length > 0)
            {
                if (value.extensions.canFind!(e => e[1..$].toLower() == lang.toLower()))
                {
                    resExtension = key;
                }
            }
        }

        return resAlias is null ? resExtension : resAlias;
    }
}
