import { getPaste } from "api/paste";
import { Paste } from "data/paste";
import * as CodeMirror from "types/codemirror/lib/codemirror";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { rawEndpoint } from "api/api";
import Page from "router/page";
import Navigation from "components/navigation";

export class PastePage extends Page
{
    public async render (): Promise<string>
    {
        /* tslint:disable:max-line-length */
        return `<h1><img class="icon" src="/assets/icons/pastemyst.svg" alt="icon"/><a route="/">PasteMyst</a></h1><p class="description">a simple website for storing and sharing code snippets.
version 2.0.0 (<a href="#" target="_blank">changelog</a>).</p><nav><ul><li><a route="/">home</a> - </li><li><a id="login" href="http://localhost:5000/auth/github">login</a> - </li><li><a href="https://github.com/codemyst/pastemyst" target="_blank">github</a> - </li><li><a href="/api-docs">api docs</a></li></ul></nav><div id="paste-header"><p class="title"></p><a class="raw">raw</a></div><textarea id="paste-content"></textarea><div id="paste-meta"><p class="created-at"><span class="highlight">created at:</span></p><p class="expires-in"><span class="highlight">expires in:</span></p></div><footer><div class="copyright">copyright &copy; <a href="https://github.com/CodeMyst" target="_blank">CodeMyst</a> 2019</div><div class="paste-amount">1337 currently active pastes</div></footer>`;
        /* tslint:enable:max-line-length */
    }

    public async run (): Promise<void>
    {
        this.addComponent (new Navigation ());

        // Get the id of the paste from the current url
        const id: string = window.location.pathname.slice (1);
        const paste: Paste = await getPaste (id);

        const title: string = paste.title ? paste.title : "no title";

        // Insert the paste title and the link to the raw paste contents
        const header: HTMLElement = document.getElementById ("paste-header");
        header.getElementsByClassName ("title") [0].textContent = title;
        header.getElementsByClassName ("raw") [0].setAttribute ("href", `${rawEndpoint}/${id}/raw`);

        // Insert the paste contents
        const textarea: HTMLTextAreaElement = document.getElementById ("paste-content") as HTMLTextAreaElement;
        const editor: CodeMirror.Editor = CodeMirror.fromTextArea (textarea,
            {
            indentUnit: 4,
            lineNumbers: true,
            tabSize: 4,
            theme: "darcula",
            readOnly: "nocursor",
            lineWrapping: true
        });
        
        editor.setValue (paste.code);

        const languageOption: LanguageOption = (await getLanguageOptions ())
                                               .find ((o) => o.mimes [0] === paste.language);

        if (languageOption.mode !== "null")
        {
            const modePath: string = `types/codemirror/mode/${languageOption.mode}/${languageOption.mode}`;
            import (modePath).then (() =>
            {
                editor.setOption ("mode", paste.language);
            });
        }
        else
        {
            editor.setOption ("mode", "text/plain");
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
            const expiresInDate: Date = new Date (this.expiresInToUnixTime (paste.expiresIn, paste.createdAt) * 1000);
            const timeDifference: number = Math.abs (expiresInDate.getTime () - new Date ().getTime ());

            expiresInContentElement.textContent = ` ${this.timeDifferenceToString (timeDifference)}`;
        }
        else
        {
            expiresInContentElement.textContent = " never";
        }

        createdAtElement.appendChild (createdAtContentElement);
        expiresInElement.appendChild (expiresInContentElement);
    }

    /**
     * Converts the expires in string to a unix time
     * 
     * @param expiresIn expires in string
     * @param unixTime unix time to which expires in is added
     */
    private expiresInToUnixTime (expiresIn: string, unixTime: number): number
    {
        let res = unixTime;

        switch (expiresIn)
        {
            case "1h":
                res += 3600;
                break;
            case "2h":
                res += 2 * 3600;
                break;
            case "10h":
                res += 10 * 3600;
                break;
            case "1d":
                res += 24 * 3600;
                break;
            case "2d":
                res += 48 * 3600;
                break;
            case "1w":
                res += 168 * 3600;
                break;
            case "never":
                res = 0;
                break;
            default: break;
        }
    
        return res;
    }

    /**
     * Converts a time difference (in milliseconds) to a string
     * 
     * @param timeDifference time in milliseconds
     */
    private timeDifferenceToString (timeDifference: number): string
    {
        let resTime: number;
        let resString: string;

        if (timeDifference <= 59000)
        {
            resTime = Math.ceil (timeDifference / 1000);
            resString = `${resTime.toString ()} seconds`;
        }
        else if (timeDifference <= 3540000)
        {
            resTime = Math.ceil (timeDifference / 60000);
            resString = `${resTime.toString ()} minutes`;
        }
        else if (timeDifference <= 82800000)
        {
            resTime = Math.ceil (timeDifference / 3600000);
            resString = `${resTime.toString ()} hours`;
        }
        else if (timeDifference <= 518400000)
        {
            resTime = Math.ceil (timeDifference / 86400000);
            resString = `${resTime.toString ()} days`;
        }

        // If the time is just one, remove the s so the time is singular
        if (resTime === 1)
        {
            resString = resString.slice (0, resString.length - 1);
        }

        return resString;
    }
}
