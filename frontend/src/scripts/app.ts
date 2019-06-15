import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { postPaste } from "api/paste";
import { Dropdown, DropdownItem } from "components/dropdown";
import { PasteCreateInfo } from "data/paste";
import { Route, Router } from "router/router";
import { Home } from "views/home";
import { Paste } from "views/paste";
import * as CodeMirror from "./types/codemirror/lib/codemirror";

let editor: CodeMirror.Editor;
let expiresInDropdown: Dropdown;
let languageDropdown: Dropdown;
let router: Router;

function initRouter ()
{
    router = new Router ();
    router.addRoute (new Route ("/", "Home", new Home ()));
    router.addRoute (new Route ("/:id", "Paste", new Paste ()));
    router.init ();
}

async function initExpiresInDropdown ()
{
    const options: ExpireOption [] = await getExpireOptions ();
    const items: DropdownItem [] = new Array<DropdownItem> (options.length);

    expiresInDropdown = new Dropdown (document.getElementById ("expires-in").children [0] as HTMLElement,
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

    languageDropdown = new Dropdown (document.getElementById ("language").children [0] as HTMLElement,
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
    editor = CodeMirror.fromTextArea (textarea,
    {
        indentUnit: 4,
        lineNumbers: true, 
        mode: "text/plain", 
        tabSize: 4,
        theme: "darcula", 
    });
}

async function createPaste ()
{
    const createInfo: PasteCreateInfo = new PasteCreateInfo ();

    createInfo.expiresIn = expiresInDropdown.selectedItem.values [0];

    const titleInput: HTMLInputElement = document.getElementById ("title-input") as HTMLInputElement;
    if (titleInput.value !== null && titleInput.value !== "")
    {
        createInfo.title = titleInput.value;
    }

    createInfo.code = editor.getValue ();
    createInfo.language = languageDropdown.selectedItem.values [1];
    createInfo.isPrivate = false;

    await postPaste (createInfo);
}

// initEditor ();

// initExpiresInDropdown ();
// initLanguageDropdown ();

// document.getElementById ("create-button").addEventListener ("click", () => createPaste ());

window.addEventListener ("hashchange", initRouter);
window.addEventListener ("load", initRouter);

initRouter ();
