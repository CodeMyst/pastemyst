import type { EndpointOutput } from "@sveltejs/kit";
import type { JSONString } from "@sveltejs/kit/types/helper";

let langsCache: JSONString;

export const get = async (): Promise<EndpointOutput> => {
    return {
        body: await getLanguages()
    };
};

/**
 *  Loading all of the languages, cached.
 */
const loadLanguages = async (): Promise<JSONString> => {
    // TODO: turn the host into a var
    const res = await fetch("http://localhost:5001/api/v3/data/langs", {
        headers: {
            "Content-Type": "application/json"
        }
    });

    const json = await res.json();

    langsCache = json;

    return json;
};

/**
 * @returns All of the languages.
 */
export const getLanguages = async (): Promise<JSONString> => {
    if (langsCache === undefined) await loadLanguages();

    return langsCache;
};