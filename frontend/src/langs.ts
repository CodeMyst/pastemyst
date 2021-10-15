let langsCache: Map<string, Language>;
let langNamesCache: [string, string][];

class Language {
    type: string;
    aliases: string[];
    codemirrorMode: string;
    codemirrorMimeType: string;
    extensions: string[];
    filenames: string[];
    color: string;
    group: string;
}

/**
 *  Loading all of the languages, cached.
 */
const loadLanguages = async () => {
    // TODO: turn the host into a var
    const res = await fetch("http://localhost:5001/api/v3/data/langs", {
        headers: {
            "Content-Type": "application/json"
        }
    });

    const langs = new Map<string, Language>();

    const json: JSON = await res.json();

    for (const langName in json) {
        const langJson = json[langName];

        const lang = new Language();
        lang.type = langJson["type"];
        lang.aliases = langJson["aliases"];
        lang.codemirrorMode = langJson["codemirrorMode"];
        lang.codemirrorMimeType = langJson["codemirrorMimeType"];
        lang.extensions = langJson["extensions"];
        lang.filenames = langJson["filenames"];
        lang.color = langJson["color"];
        lang.group = langJson["gruop"];

        langs.set(langName, lang);
    }

    langsCache = langs;
};

/**
 * @returns All of the languages.
 */
export const getLanguages = async (): Promise<Map<string, Language>> => {
    if (langsCache === undefined) await loadLanguages();

    return langsCache;
};

/**
 * Loading all the languages from the API as a [String, String] where both values are the language name.
 *
 * Used for showing in dropdowns.
 */
export const getLanguageNames = async (): Promise<[string, string][]> => {
    if (langNamesCache !== undefined) return langNamesCache;

    const names = new Array<[string, string]>();

    for (const [k, v] of await getLanguages()) {
        let val = "";
        if (v.aliases !== null) val = v.aliases.join(", ");
        names.push([val, k]);
    }

    langNamesCache = names;

    return names;
};

/**
 * Returns a language by its name.
 */
export const getLanguage = async (lang: string): Promise<Language> => {
    const langs = await getLanguages();

    return langs.get(lang);
};
