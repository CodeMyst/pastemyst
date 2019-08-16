import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { postPaste } from "api/paste";
import { Dropdown, DropdownItem } from "components/dropdown";
import { Paste, PasteCreateInfo } from "data/paste";
import * as CodeMirror from "types/codemirror/lib/codemirror";
import View from "renderer/view";

export default class Home extends View
{
    private editor: CodeMirror.Editor;
    private expiresInDropdown: Dropdown;
    private languageDropdown: Dropdown;

    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<div class="options"><div id="expires-in"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="/assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..." autocomplete="off"/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div><div id="language"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="/assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..." autocomplete="off"/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div></div><input id="title-input" type="text" name="title" placeholder="title (optional)" autocomplete="off"/><textarea id="editor" autofocus="autofocus"></textarea><div class="create-options"><div class="private-checkbox"><label class="disabled">private<input type="checkbox" disabled="disabled"/><span class="checkmark"></span></label><div class="tooltip" data-tooltip="You need to be logged in to create private pastes."><img src="/assets/icons/questionmark.svg" alt="questionmark"/></div></div><a class="button" id="create-button">create</a></div>`;
        /* tslint:enable:max-line-length */        
    }

    public async run (): Promise<void>
    {
        this.initEditor ();

        this.initExpiresInDropdown ();
        this.initLanguageDropdown ();

        document.getElementById ("create-button").addEventListener ("click", async () =>
        {
            const paste: Paste = await this.createPaste ();

            window.history.pushState ({}, document.title, paste._id);
            window.dispatchEvent (new Event ("popstate"));
        });
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

    private async initLanguageDropdown (): Promise<void>
    {
        const options: LanguageOption [] = await getLanguageOptions ();
        const items: DropdownItem [] = new Array<DropdownItem> (options.length);

        this.languageDropdown = new Dropdown (document.getElementById ("language").children [0] as HTMLElement,
                                                "language:",
                                                true);
        
        for (let i = 0; i < options.length; i++)
        {
            items [i] = new DropdownItem ([options [i].mode, options [i].mimes [0]], options [i].name);
            this.languageDropdown.addItem (items [i]);
        }

        this.languageDropdown.selectItem (items [0]);

        this.languageDropdown.onChange = (item: DropdownItem) =>
        {
            if (item.values [0] !== "null")
            {
                const modePath = `../types/codemirror/mode/${item.values [0]}/${item.values [0]}`;
                import (modePath).then (() =>
                {
                    this.editor.setOption ("mode", item.values [1]);
                });
            }
            else
            {
                this.editor.setOption ("mode", item.values [0]);
            }
        };
    }

    private initEditor (): void
    {
        const textarea: HTMLTextAreaElement = document.getElementById ("editor") as HTMLTextAreaElement;
        this.editor = CodeMirror.fromTextArea (textarea,
        {
            indentUnit: 4,
            lineNumbers: false, 
            mode: "text/plain", 
            tabSize: 4,
            theme: "darcula",
            lineWrapping: true
        });
    }

    private async createPaste (): Promise<Paste>
    {
        const createInfo: PasteCreateInfo = new PasteCreateInfo ();

        createInfo.expiresIn = this.expiresInDropdown.selectedItem.values [0];

        const titleInput: HTMLInputElement = document.getElementById ("title-input") as HTMLInputElement;
        if (titleInput.value !== null && titleInput.value !== "")
        {
            createInfo.title = titleInput.value;
        }

        createInfo.code = this.editor.getValue ();
        createInfo.language = this.languageDropdown.selectedItem.values [1];
        createInfo.isPrivate = false;

        return await postPaste (createInfo);
    }
}
