import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { postPaste } from "api/paste";
import { Dropdown, DropdownItem } from "components/dropdown";
import { Paste, PasteCreateInfo } from "data/paste";
import * as CodeMirror from "types/codemirror/lib/codemirror";
import Page from "router/page";
import Navigation from "components/navigation";
import Modal from "components/modal";

export class HomePage extends Page
{
    private editor: CodeMirror.Editor;
    private expiresInDropdown: Dropdown;
    private languageDropdown: Dropdown;

    public async render (): Promise<string>
    {
        /* tslint:disable:max-line-length */
        return `<div class="modal" id="login-modal"><div class="content"><div class="head"><p class="title">login</p><img class="exit" src="/assets/icons/exit.svg"/></div><div class="body"><p>logging in with github you'll be able to do many more things, like seeing a list of all pastes you made, creating private pastes which can only be accessed with your account, labeling pastes and organizing them, and much more.</p><p>only your github id and username will be stored to uniquely identify you and nothing more.</p></div><div class="footer"><a href="http://api.paste.myst/auth/github">login with github</a></div></div></div><h1><img class="icon" src="/assets/icons/pastemyst.svg" alt="icon"/><a route="/">PasteMyst</a></h1><p class="description">a simple website for storing and sharing code snippets.
version 2.0.0 (<a href="#" target="_blank">changelog</a>).</p><nav><ul><li><a route="/">home</a> - </li><li><a id="login">login</a> - </li><li><a href="https://github.com/codemyst/pastemyst" target="_blank">github</a> - </li><li><a href="/api-docs">api docs</a></li></ul></nav><div class="options"><div id="expires-in"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="/assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..." autocomplete="off"/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div><div id="language"><div class="dropdown hidden"><div class="label"><p>label:</p></div><div class="dropdown-content"><div class="clickable"><p class="selected">loading...</p><img class="caret" src="/assets/icons/caret.svg"/></div><div class="selectable"><input class="search" type="text" name="search" placeholder="search..." autocomplete="off"/><div class="items"><p class="not-found hidden">no items found</p></div></div></div></div></div></div><input id="title-input" type="text" name="title" placeholder="title (optional)" autocomplete="off"/><textarea id="editor" autofocus="autofocus"></textarea><div class="create-options"><div class="private-checkbox"><label class="disabled">private<input type="checkbox" disabled="disabled"/><span class="checkmark"></span></label><div class="tooltip" data-tooltip="You need to be logged in to create private pastes."><img src="/assets/icons/questionmark.svg" alt="questionmark"/></div></div><a class="button" id="create-button">create</a></div><footer><div class="copyright">copyright &copy; <a href="https://github.com/CodeMyst" target="_blank">CodeMyst</a> 2019</div><div class="paste-amount">1337 currently active pastes</div></footer>`;
        /* tslint:enable:max-line-length */        
    }

    public async run (): Promise<void>
    {
        this.addComponent (new Navigation ());
        this.addComponent (new Modal ("login-modal"));

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
            lineNumbers: true, 
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
