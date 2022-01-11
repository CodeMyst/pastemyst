import { INDENT_AMOUNTS, INDENT_UNITS } from "./constants";

export interface GlobalSettings {
    indentUnit: [string, string];
    indentAmount: [string, string];
    overrideIndentation: boolean;
    defaultLang: [string, string];
    fullWidth: boolean;
}

export const getGlobalSettings = (): GlobalSettings => {
    // TODO: get these from local storage / profile
    return {
        indentUnit: INDENT_UNITS[1], // spaces
        indentAmount: INDENT_AMOUNTS[3], // 4 wide
        overrideIndentation: false,
        defaultLang: ["fundamental, plain text", "Text"],
        fullWidth: false
    };
};