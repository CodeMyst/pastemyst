import { getPaste } from "api/paste";
import * as data from "data/paste";
import * as CodeMirror from "types/codemirror/lib/codemirror";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { rawEndpoint } from "api/api";
import View from "renderer/view";
import { expiresInToUnixTime, timeDifferenceToString } from "time/time";

export default class Paste extends View
{
    private editors: CodeMirror.Editor [] = new Array<CodeMirror.Editor> ();

    public render (): string
    {
        /* tslint:disable:max-line-length */
        return `<div id="paste-header"><div class="title"><img class="lock" src="/assets/icons/lock.svg"/><p></p></div></div><div id="paste-pasties"><div class="pastie"><div class="pastie-header"><p class="title"></p><a class="raw">raw</a></div><div class="pastie-content"><textarea></textarea></div></div></div><div id="paste-meta"><p class="created-at"><span class="highlight">created at:</span></p><p class="expires-in"><span class="highlight">expires in:</span></p></div>`;
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
        
        const titleElement = header.getElementsByClassName ("title") [0];
        titleElement.getElementsByTagName ("p") [0].textContent = title;

        if (paste.isPrivate)
        {
            (titleElement.getElementsByClassName ("lock") [0] as HTMLElement).style.display = "block";
        }

        const languageOptions: LanguageOption [] = await getLanguageOptions ();

        paste.pasties.forEach ((p, i) =>
        {
            const clone = document.querySelector ("#paste-pasties .pastie").cloneNode (true) as HTMLElement;

            const pastieHeader = clone.getElementsByClassName ("pastie-header") [0];

            (pastieHeader.getElementsByClassName ("title") [0] as HTMLElement).textContent =
                p.title ? p.title : "no title";
            
            pastieHeader.getElementsByClassName ("raw") [0].setAttribute ("href",
                `${rawEndpoint}/${paste._id}/${i}/raw`);

            const textarea: HTMLTextAreaElement = clone.getElementsByTagName ("textarea") [0];
            const editor = CodeMirror.fromTextArea (textarea,
            {
                indentUnit: 4,
                lineNumbers: true,
                tabSize: 4,
                theme: "darcula",
                readOnly: "nocursor",
                lineWrapping: true
            });

            editor.setValue (p.code);

            const languageOption: LanguageOption = languageOptions.find ((o) => o.mimes [0] === p.language);

            if (languageOption.mode !== "null")
            {
                const modePath: string = `types/codemirror/mode/${languageOption.mode}/${languageOption.mode}`;
                import (modePath).then (() =>
                {
                    editor.setOption ("mode", p.language);
                });
            }
            else
            {
                editor.setOption ("mode", "text/plain");
            }

            this.editors.push (editor);

            document.getElementById ("paste-pasties").appendChild (clone);
        });

        document.querySelector ("#paste-pasties .pastie").remove ();

        // Insert the created at and expires in values
        const createdAt: Date = new Date (paste.createdAt * 1000);

        const meta: HTMLElement = document.getElementById ("paste-meta");

        const createdAtElement: Element = meta.getElementsByClassName ("created-at") [0];
        const createdAtContentElement: Element = document.createElement ("span");

        createdAtContentElement.textContent = ` ${createdAt.toString ().toLowerCase ()}`;

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
        this.editors.forEach ((e) =>
        {
            e.refresh ();
        });
    }
}
