import type { EndpointOutput } from "@sveltejs/kit";
import { API_BASE } from "../../constants";
import { getHighlighter, loadTheme } from "shiki";

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const get = async ({ params }): Promise<EndpointOutput> => {
    const { paste } = params;
    const res = await fetch(`${API_BASE}/paste/${paste}`);
    const pasteJson = await res.json();

    const highlightedContent = new Array<string>();

    // todo: proper themes
    const darculaTheme = await loadTheme("../../src/themes/darcula.json");

    const highligher = await getHighlighter({ theme: darculaTheme });
    for (const pasty of pasteJson.pasties) {
        // todo: proper language
        const code = highligher.codeToHtml(pasty.content, "cpp");
        highlightedContent.push(code);
    }

    return {
        body: {
            paste: pasteJson,
            highlightedContent: highlightedContent
        }
    };
};