import { INDENT_AMOUNTS, INDENT_UNITS } from "./constants";
import { getLangNames } from "./services/langs";

export interface GlobalSettings {
    indentUnit: [string, string];
    indentAmount: [string, string];
    overrideIndent: boolean;
    defaultLang: [string, string];
    fullWidth: boolean;
}

const SETTING_INDENT_UNIT = "settings.indentUnit";
const SETTING_INDENT_AMOUNT = "settings.indentAmount";
const SETTING_OVERRIDE_INDENT = "settings.overrideIndent";
const SETTING_DEFAULT_LANG = "settings.defaultLang";
const SETTING_FULL_WIDTH = "settings.fullWidth";

export const getGlobalSettings = async (): Promise<GlobalSettings> => {
    const res = <GlobalSettings>{};

    if (localStorage.getItem(SETTING_INDENT_UNIT)) {
        res.indentUnit = INDENT_UNITS.find(e => e[1] === localStorage.getItem(SETTING_INDENT_UNIT));
    } else {
        res.indentUnit = INDENT_UNITS[1]; // spaces
    }

    if (localStorage.getItem(SETTING_INDENT_AMOUNT)) {
        res.indentAmount = INDENT_AMOUNTS.find(e => e[1] === localStorage.getItem(SETTING_INDENT_AMOUNT));
    } else {
        res.indentAmount = INDENT_AMOUNTS[3]; // 4 wide
    }

    if (localStorage.getItem(SETTING_OVERRIDE_INDENT)) {
        res.overrideIndent = localStorage.getItem(SETTING_OVERRIDE_INDENT) === "true";
    } else {
        res.overrideIndent = false;
    }

    if (localStorage.getItem(SETTING_DEFAULT_LANG)) {
        res.defaultLang = (await getLangNames()).find(e => e[1] === localStorage.getItem(SETTING_DEFAULT_LANG));
    } else {
        res.defaultLang = ["fundamental, plain text", "Text"];
    }

    if (localStorage.getItem(SETTING_FULL_WIDTH)) {
        res.fullWidth = localStorage.getItem(SETTING_FULL_WIDTH) === "true";
    } else {
        res.fullWidth = false;
    }

    return res;
};

export const saveGlobalSettings = (settings: GlobalSettings): void => {
    // TODO: saving to profile
    localStorage.setItem(SETTING_INDENT_UNIT, settings.indentUnit[1]);
    localStorage.setItem(SETTING_INDENT_AMOUNT, settings.indentAmount[1]);
    localStorage.setItem(SETTING_OVERRIDE_INDENT, String(settings.overrideIndent));
    localStorage.setItem(SETTING_DEFAULT_LANG, settings.defaultLang[1]);
    localStorage.setItem(SETTING_FULL_WIDTH, String(settings.fullWidth));
};