import type { EndpointOutput } from "@sveltejs/kit";
import { API_BASE } from "../../constants";
import { getHighlighter, loadTheme } from "shiki";

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const get = async ({ params }): Promise<EndpointOutput> => {
    const { paste } = params;

    const pasteRes = await fetch(`${API_BASE}/paste/${paste}`);
    const pasteJson = await pasteRes.json();

    const highlightedContent = new Array<string>();

    const darculaTheme = await loadTheme("../../src/themes/darcula.json");

    const highligher = await getHighlighter({ theme: darculaTheme, langs: ["cpp"], themes: [] });
    for (const pasty of pasteJson.pasties) {
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
