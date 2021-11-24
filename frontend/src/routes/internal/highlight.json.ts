import type { EndpointOutput } from "@sveltejs/kit";
import type {ServerRequest} from "@sveltejs/kit/types/hooks";
import { getHighlighter, ILanguageRegistration, loadTheme } from "shiki";

// highlights the provided code using shiki

export const post = async (request: ServerRequest): Promise<EndpointOutput> => {
    const content = request.body["content"];
    let languageName = request.body["languageName"];
    const languageScope = request.body["languageScope"];

    // todo: themes
    const theme = "darcula";

    const langPath = `../../grammars/${languageScope}.json`;

    const langs: ILanguageRegistration[] = [];

    // TODO: for now there is only one grammar file for testing
    if (languageName === "D") {
        const shikiLang: ILanguageRegistration = {
            id: languageName,
            scopeName: languageScope,
            path: langPath
        };
        langs.push(shikiLang);
    } else {
        languageName = null;
    }

    // todo: caching
    const shikiTheme = await loadTheme(`../../src/themes/${theme}.json`);

    const highligher = await getHighlighter({ theme: shikiTheme, langs: langs });

    const res = highligher.codeToHtml(content, languageName);

    return {
        body: {
            res: res
        }
    };
};
