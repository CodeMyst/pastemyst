import type { EndpointOutput } from "@sveltejs/kit";
import { API_BASE } from "../../constants";
import {highlight} from "./highlight.json";

/**
 * @returns The paste and the highlighted content
 */
// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const get = async ({ params }): Promise<EndpointOutput> => {
    const { paste } = params;

    const pasteRes = await fetch(`${API_BASE}/paste/${paste}`);
    const pasteJson = await pasteRes.json();

    const highlightedContent = new Array<string>();
    for (const pasty of pasteJson.pasties) {
        highlightedContent.push(await highlight(pasty.content, pasty.language));
    }

    return {
        body: {
            paste: pasteJson,
            highlightedContent: highlightedContent
        }
    };
};
