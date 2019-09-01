import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { postPaste } from "api/paste";
import { Dropdown, DropdownItem } from "components/dropdown";
import { Paste, PasteCreateInfo, Pasty } from "data/paste";
import * as CodeMirror from "types/codemirror/lib/codemirror";
import View from "renderer/view";
import { isLoggedIn } from "api/auth";

export default class Home extends View
{
    private editors: PastyEditor [] = new Array<PastyEditor> ();

    private expiresInDropdown: Dropdown;
    private privateCheckbox: Element;

    private isLoggedIn: boolean = false;

    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<div class="title"><input id="title-input" type="text" name="title" placeholder="title (optional)" autocomplete="off"/><div id="expires-in"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="/assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..." autocomplete="off"/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div></div><div class="pasty-editors"><div class="pasty-editor"><div class="pasty-title"><input type="text" name="pasty-title" placeholder="pasty title (optional)" autocomplete="off"/><div class="language"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="/assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..." autocomplete="off"/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div></div><textarea autofocus="autofocus"></textarea></div></div><a class="pasty-button">+ add another pasty</a><div class="create-options"><div class="private-checkbox"><label class="disabled">private<input type="checkbox" disabled="disabled"/><span class="checkmark"></span></label><div class="tooltip" data-tooltip="You need to be logged in to create private pastes."><img src="/assets/icons/questionmark.svg" alt="questionmark"/></div></div><a class="button" id="create-button">create</a></div>`;
        /* tslint:enable:max-line-length */        
    }

    public async run (): Promise<void>
    {
        this.isLoggedIn = await isLoggedIn ();

        this.initExpiresInDropdown ();

        this.initEditors ();

        document.getElementById ("create-button").addEventListener ("click", async () =>
        {
            const paste: Paste = await this.createPaste ();

            window.history.pushState ({}, document.title, paste._id);
            window.dispatchEvent (new Event ("popstate"));
        });

        document.getElementsByClassName ("pasty-button") [0].addEventListener ("click", () => this.addEditor ());

        if (this.isLoggedIn)
        {
            this.privateCheckbox = document.getElementsByClassName ("private-checkbox") [0];
            this.privateCheckbox.getElementsByTagName ("input") [0].disabled = false;
            this.privateCheckbox.getElementsByTagName ("label") [0].classList.remove ("disabled");
            this.privateCheckbox.getElementsByClassName ("tooltip") [0]
                .setAttribute ("data-tooltip", "Private pastes are visible only to you.");
        }
    }

    public async postRun (): Promise<void>
    {
        this.editors [0].editor.refresh ();
        this.editors [0].editor.focus ();
    }

    private async initExpiresInDropdown (): Promise<void>
    {
        const options: ExpireOption [] = await getExpireOptions ();
        const items: DropdownItem [] = new Array<DropdownItem> (options.length);

        this.expiresInDropdown = new Dropdown (document.getElementById ("expires-in").children [0] as HTMLElement,
                                                "expires in:",
                                                false);
        
        for (let i = 0; i < options.length; i++)
        {
            items [i] = new DropdownItem ([options [i].value], options [i].pretty);
            this.expiresInDropdown.addItem (items [i]);
        }

        this.expiresInDropdown.selectItem (items [0]);
    }

    private async initLanguageDropdown (editor: PastyEditor): Promise<void>
    {
        const options: LanguageOption [] = await getLanguageOptions ();
        const items: DropdownItem [] = new Array<DropdownItem> (options.length);

        editor.languageDropdown = new Dropdown
        (
            editor.rootElement.getElementsByClassName ("language") [0].children [0] as HTMLElement,
            "language:",
            true
        );
        
        for (let i = 0; i < options.length; i++)
        {
            items [i] = new DropdownItem ([options [i].mode, options [i].mimes [0]], options [i].name);
            editor.languageDropdown.addItem (items [i]);
        }

        editor.languageDropdown.selectItem (items [0]);

        editor.languageDropdown.onChange = (item: DropdownItem) =>
        {
            if (item.values [0] !== "null")
            {
                const modePath = `../types/codemirror/mode/${item.values [0]}/${item.values [0]}`;
                import (modePath).then (() =>
                {
                    editor.editor.setOption ("mode", item.values [1]);
                });
            }
            else
            {
                editor.editor.setOption ("mode", item.values [0]);
            }
        };
    }

    private initEditors (): void
    {
        const editor: PastyEditor = new PastyEditor ();

        editor.rootElement = document.getElementsByClassName ("pasty-editor") [0] as HTMLElement;

        editor.titleInput = document.querySelector (".pasty-title input") as HTMLInputElement;

        const textarea: HTMLTextAreaElement = document.querySelector (".pasty-editor textarea") as HTMLTextAreaElement;
        editor.editor = CodeMirror.fromTextArea (textarea,
        {
            indentUnit: 4,
            lineNumbers: true, 
            mode: "text/plain", 
            tabSize: 4,
            theme: "darcula",
            lineWrapping: true
        });

        this.initLanguageDropdown (editor);

        this.editors.push (editor);
    }

    private addEditor (): void
    {
        const editor: PastyEditor = new PastyEditor ();

        const clone: HTMLElement = this.editors [this.editors.length - 1].rootElement.cloneNode (true) as HTMLElement;

        editor.rootElement = clone;

        clone.getElementsByClassName ("CodeMirror") [0].remove ();

        this.initLanguageDropdown (editor);

        editor.titleInput = clone.querySelector (".pasty-title input") as HTMLInputElement;
        editor.titleInput.value = "";

        const textarea: HTMLTextAreaElement = clone.querySelector (".pasty-editor textarea") as HTMLTextAreaElement;
        editor.editor = CodeMirror.fromTextArea (textarea,
        {
            indentUnit: 4,
            lineNumbers: true, 
            mode: "text/plain", 
            tabSize: 4,
            theme: "darcula",
            lineWrapping: true
        });

        document.getElementsByClassName ("pasty-editors") [0].appendChild (clone);
        
        this.editors.push (editor);

        editor.editor.refresh ();
        editor.editor.focus ();
    }

    private async createPaste (): Promise<Paste>
    {
        const createInfo: PasteCreateInfo = new PasteCreateInfo ();

        createInfo.expiresIn = this.expiresInDropdown.selectedItem.values [0];

        const titleInput: HTMLInputElement = document.getElementById ("title-input") as HTMLInputElement;
        createInfo.title = titleInput.value;

        createInfo.pasties = new Array<Pasty> ();

        this.editors.forEach ((e) =>
        {
            const pasty: Pasty = new Pasty ();

            pasty.code = e.editor.getValue ();
            pasty.language = e.languageDropdown.selectedItem.values [1];
            pasty.title = e.titleInput.value;

            createInfo.pasties.push (pasty);
        });

        if (this.isLoggedIn)
        {
            createInfo.isPrivate = this.privateCheckbox.getElementsByTagName ("input") [0].checked;
        }
        else
        {
            createInfo.isPrivate = false;
        }

        return await postPaste (createInfo);
    }
}

class PastyEditor
{
    public rootElement: HTMLElement;

    public titleInput: HTMLInputElement;    
    public languageDropdown: Dropdown;
    public editor: CodeMirror.Editor;
}
