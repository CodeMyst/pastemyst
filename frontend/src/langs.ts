let langsCache: [String, String][];

/**
 * Loading all the languages from the API.
 */
export async function loadLangs(): Promise<[String, String][]> {
    if (langsCache !== undefined) return langsCache;

    // TODO: turn the host into a var
    let res = await fetch("http://localhost:5001/api/v3/data/langs", {
        headers: {
            "Content-Type": "application/json",
        },
    });

    let json: JSON = await res.json();

    let langs: [String, String][] = new Array<[String, String]>();

    for (let lang in json) {
        langs.push([lang, lang]);
    }

    langsCache = langs;

    return langs;
}