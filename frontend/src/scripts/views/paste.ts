import { getPaste } from "api/paste";
import * as data from "data/paste";
import * as CodeMirror from "types/codemirror/lib/codemirror";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { rawEndpoint } from "api/api";
import View from "renderer/view";
import { expiresInToUnixTime, timeDifferenceToString } from "time/time";

export default class Paste extends View
{
    private editor: CodeMirror.Editor;

    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<div id="paste-header"><p class="title"></p><a class="raw">raw</a></div><textarea id="paste-content"></textarea><div id="paste-meta"><p class="created-at"><span class="highlight">created at:</span></p><p class="expires-in"><span class="highlight">expires in:</span></p></div>`;
        /* tslint:enable:max-line-length */
    }

    public async run (): Promise<void>
    {
        // Get the id of the paste from the current url
        const id: string = window.location.pathname.slice (1);
        const paste: data.Paste = await getPaste (id);

        const title: string = paste.title ? paste.title : "no title";

        // Insert the paste title and the link to the raw paste contents
        const header: HTMLElement = document.getElementById ("paste-header");
        header.getElementsByClassName ("title") [0].textContent = title;
        header.getElementsByClassName ("raw") [0].setAttribute ("href", `${rawEndpoint}/${id}/raw`);

        // Insert the paste contents
        const textarea: HTMLTextAreaElement = document.getElementById ("paste-content") as HTMLTextAreaElement;
        this.editor = CodeMirror.fromTextArea (textarea,
        {
            indentUnit: 4,
            lineNumbers: true,
            tabSize: 4,
            theme: "darcula",
            readOnly: "nocursor",
            lineWrapping: true
        });
        
        this.editor.setValue (paste.code);

        const languageOption: LanguageOption = (await getLanguageOptions ())
                                               .find ((o) => o.mimes [0] === paste.language);

        if (languageOption.mode !== "null")
        {
            const modePath: string = `types/codemirror/mode/${languageOption.mode}/${languageOption.mode}`;
            import (modePath).then (() =>
            {
                this.editor.setOption ("mode", paste.language);
            });
        }
        else
        {
            this.editor.setOption ("mode", "text/plain");
        }

        // Insert the created at and expires in values
        const createdAt: Date = new Date (paste.createdAt * 1000);

        const meta: HTMLElement = document.getElementById ("paste-meta");

        const createdAtElement: Element = meta.getElementsByClassName ("created-at") [0];
        const createdAtContentElement: Element = document.createElement ("span");

        createdAtContentElement.textContent = ` ${createdAt}`;

        const expiresInElement: Element = meta.getElementsByClassName ("expires-in") [0];
        const expiresInContentElement: Node = document.createElement ("span");

        if (paste.expiresIn !== "never")
        {
            const expiresInDate: Date = new Date (expiresInToUnixTime (paste.expiresIn, paste.createdAt) * 1000);
            const timeDifference: number = Math.abs (expiresInDate.getTime () - new Date ().getTime ());

            expiresInContentElement.textContent = ` ${timeDifferenceToString (timeDifference)}`;
        }
        else
        {
            expiresInContentElement.textContent = " never";
        }

        createdAtElement.appendChild (createdAtContentElement);
        expiresInElement.appendChild (expiresInContentElement);
    }

    public async postRun (): Promise<void>
    {
        this.editor.refresh ();
    }
}
