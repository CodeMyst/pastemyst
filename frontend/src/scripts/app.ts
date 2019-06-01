import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { Dropdown, DropdownItem, OnChangeDelegate } from "components/dropdown";
import * as CodeMirror from "./types/codemirror/lib/codemirror";

let editor: CodeMirror.Editor;

async function initExpiresInDropdown ()
{
    const options: ExpireOption [] = await getExpireOptions ();
    const items: DropdownItem [] = new Array<DropdownItem> (options.length);

    const expiresInDropdown = new Dropdown (document.getElementById ("expires-in").children [0] as HTMLElement,
                                            "expires in:",
                                            false);
    
    for (let i = 0; i < options.length; i++)
    {
        items [i] = new DropdownItem ([options [i].value], options [i].pretty);
        expiresInDropdown.addItem (items [i]);
    }

    expiresInDropdown.selectItem (items [0]);
}

async function initLanguageDropdown ()
{
    const options: LanguageOption [] = await getLanguageOptions ();
    const items: DropdownItem [] = new Array<DropdownItem> (options.length);

    const languageDropdown = new Dropdown (document.getElementById ("language").children [0] as HTMLElement,
                                            "language:",
                                            true);
    
    for (let i = 0; i < options.length; i++)
    {
        items [i] = new DropdownItem ([options [i].mode, options [i].mimes [0]], options [i].name);
        languageDropdown.addItem (items [i]);
    }

    languageDropdown.selectItem (items [0]);

    languageDropdown.onChange = (item: DropdownItem) =>
    {
        if (item.values [0] !== "null")
        {
            const modePath = `./types/codemirror/mode/${item.values [0]}/${item.values [0]}`;
            import (modePath).then (() =>
            {
                editor.setOption ("mode", item.values [1]);
            });
        }
        else
        {
            editor.setOption ("mode", item.values [0]);
        }
    };
}

function initEditor ()
{
    const textarea: HTMLTextAreaElement = document.getElementById ("editor") as HTMLTextAreaElement;
    editor = CodeMirror.fromTextArea (textarea, { theme: "base16-dark", lineNumbers: true, mode: "text/plain" });
}

initEditor ();

initExpiresInDropdown ();
initLanguageDropdown ();
