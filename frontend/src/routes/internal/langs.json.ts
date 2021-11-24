import type { EndpointOutput } from "@sveltejs/kit";
import type { JSONString } from "@sveltejs/kit/types/helper";
import { API_BASE } from "../../constants";

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
    const res = await fetch(`${API_BASE}/data/langs`, {
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
