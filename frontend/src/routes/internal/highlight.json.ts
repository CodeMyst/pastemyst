import type { EndpointOutput } from "@sveltejs/kit";
import { getHighlighter, loadTheme } from "shiki";

// highlights the provided code using shiki

// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
export const post = async (request): Promise<EndpointOutput> => {
    const content = request.body.content;
    const languageName = request.body.languageName;
    const languageScope = request.body.languageScope;

    // todo: themes
    const theme = "darcula";

    console.log(request.body);

    // todo: caching
    const shikiTheme = await loadTheme(`../../src/themes/${theme}.json`);
    const shikiLang = {
        id: languageName,
        scopeName: languageScope,
        path: `../../grammars/${languageScope}.json`
    };

    const highligher = await getHighlighter({ theme: shikiTheme, langs: [shikiLang] });

    const res = highligher.codeToHtml(content, languageName);

    return {
        body: {
            res: res
        }
    };
};
