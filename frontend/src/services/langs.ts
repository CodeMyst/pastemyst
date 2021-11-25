import { Language } from "../models/Language";
import { API_BASE } from "../constants";

let langsCache = new Map<string, Language>();

/**
 * @returns All of the languages, first call is not cached.
 */
export const getLangs = async (): Promise<Map<string, Language>> => {
    if (langsCache.size == 0) await loadLangs();

    return langsCache;
};

/**
 * Loads all the languages from the API, stores the result in a cache,
 * so it only needs to get called once.
 */
const loadLangs = async (): Promise<Map<string, Language>> => {
    const res = await fetch(`${API_BASE}/data/langs`);

    const json = await res.json();

    const langs = new Map<string, Language>();

    // custom converstion because doesn't work automatically
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
        lang.tmScope = langJson["tmScope"];
        langs.set(langName, lang);
    }

    langsCache = langs;

    return langsCache;
};
