import type { EndpointOutput } from "@sveltejs/kit";
import type {ServerRequest} from "@sveltejs/kit/types/hooks";
import { getHighlighter, Highlighter, loadTheme } from "shiki";

// highlights the provided code using shiki

let highlighter: Highlighter;

/**
 * Endpoint for highlight content.
 */
export const post = async (request: ServerRequest): Promise<EndpointOutput> => {
    const content = request.body["content"];

    const languageName = request.body["languageName"];
    // const languageScope = request.body["languageScope"];

    return {
        body: await highlight(content, languageName)
    };
};

export const highlight = async (content: string, language: string): Promise<string> => {
    if (highlighter === undefined) await loadHighlighter();

    return highlighter.codeToHtml(content, language);
};

const loadHighlighter = async () => {
    // TODO: themes
    const theme = await loadTheme(`../../src/themes/darcula.json`);

    // TODO: for now there is only one grammar file for testing
    const lang = {
        id: "D",
        scopeName: "source.d",
        path: "../../grammars/source.d.json"
    };

    highlighter = await getHighlighter({ theme: theme, langs: [lang] });
};
