import { timeDifferenceToString } from "../helpers/time.js";
import { getWordwrap, getTheme } from "../helpers/options.js";

let highlightExpr = /(\d)L(\d+)(?:-L(\d+))?/;
let editors = [];
let highlightedLines = [];

window.addEventListener("load", async () =>
{
    let textareas = document.querySelectorAll("textarea");

    let langCache = new Map();

    for (let i = 0; i < textareas.length; i++)
    {
        let editor = CodeMirror.fromTextArea(textareas[i], // jshint ignore:line
        {
            indentUnit: 4,
            lineNumbers: true,
            mode: "text/plain",
            tabSize: 4,
            theme: getTheme(),
            lineWrapping: getWordwrap(),
            readOnly: true,
            extraKeys:
            {
                Tab: (cm) => cm.execCommand("insertSoftTab")
            }
        });

        if (textareas[i].classList.length > 0)
        {
            editor.getWrapperElement().classList.add(textareas[i].classList);
        }

        let langMime;
        let langColor;

        if (langCache.has(langs[i])) // jshint ignore:line
        {
            langMime = langCache.get(langs[i])[0]; // jshint ignore:line
        }
        else
        {
            let res = await fetch(`/api/v2/data/language?name=${encodeURIComponent(langs[i])}`, // jshint ignore:line
            {
                headers:
                {
                    "Content-Type": "application/json"
                }
            });

            let langData = await res.json();

            if (langData.mode && langData.mode !== "null")
            {
                await import(`../libs/codemirror/${langData.mode}/${langData.mode}.js`).then(() => // jshint ignore:line
                {
                    langMime = langData.mimes[0];
                    langCache.set(langs[i], [langData.mimes[0], langData.color]); // jshint ignore:line
                });
            }
            else
            {
                langMime = "text/plain";
                langCache.set(langs[i], ["text/plain", "#ffffff"]);
            }
        }

        editor.setOption("mode", langMime);

        langColor = langCache.get(langs[i])[1]; // jshint ignore:line

        if (langColor)
        {
            let langTextElem = textareas[i].closest(".pasty").getElementsByClassName("lang")[0];

            langTextElem.style.backgroundColor = langColor;

            if (getColor(langColor))
            {
                langTextElem.style.color = "white";
            }
            else
            {
                langTextElem.style.color = "black";
            }
        }

        editors.push(editor);

        let lines = editor.getWrapperElement().getElementsByClassName("CodeMirror-linenumber");

        let start;
        let end;

        for (let j = 0; j < lines.length; j++)
        {
            lines[j].addEventListener("click", (e) => // jshint ignore:line
            {
                if (!e.shiftKey)
                {
                    // start marker
                    start = j+1;
                    end = undefined;
                }
                else
                {
                    // end marker
                    if (start === undefined)
                    {
                        start = j+1;
                    }
                    else
                    {
                        if ((j+1) < start)
                        {
                            end = start;
                            start = j+1;
                        }
                        else
                        {
                            end = j+1;
                        }
                    }
                }

                if (end !== undefined)
                {
                    location.hash = i + "L" + start + "-L" + end;
                }
                else
                {
                    location.hash = i + "L" + start;
                }

                highlightLines();
            });
        }
    }

    highlightLines();
    jumpToHighlight();

    let createdAtDate = new Date(createdAt * 1000); // jshint ignore:line

    document.querySelector(".paste-meta .created-at .value").textContent = " " + createdAtDate.toString().toLowerCase();

    if (deletesAt !== 0) // jshint ignore:line
    {
        let expiresIn = timeDifferenceToString(deletesAt * 1000 - new Date()); // jshint ignore:line
        document.querySelector(".paste-meta .expires-in .value").textContent = " " + expiresIn;
    }

    let editedAtDate = new Date(editedAt * 1000); // jshint ignore:line

    if (editedAt !== 0) // jshint ignore:line
    {
        document.querySelector(".paste-meta .edited-at .value").textContent = " " + editedAtDate.toString().toLowerCase();
    }

    let copyButtons = document.querySelectorAll("#paste .paste-pasties .pasty .pasty-header .copy");

    for (let i = 0; i < copyButtons.length; i++)
    {
        copyButtons[i].addEventListener("click", () => copyCodeToClipboard(copyButtons[i])); // jshint ignore:line
    }

    let copyLinkButton = document.querySelector("#paste .paste-header .copy-link");
    let copyLink = copyLinkButton.getAttribute("href");
    copyLinkButton.addEventListener("click", () => copyLinkToClipboard(copyLink));
    copyLinkButton.removeAttribute("href");

    let copyLinkEditButton = document.querySelector("#paste .paste-header .copy-link-edit");
    let copyEditLink = copyLinkEditButton.getAttribute("href");
    copyLinkEditButton.addEventListener("click", () => copyLinkToClipboard(copyEditLink));
    copyLinkEditButton.removeAttribute("href");

    const embedScriptCopy = document.querySelector(".embed-script-copy");
    const embedScript = document.querySelector(".embed-script");
    embedScriptCopy.addEventListener("click", () => copyToClipboard(embedScript.value));
});

function copyCodeToClipboard(copyButton)
{
    let textarea = copyButton.closest(".pasty").querySelector("textarea");

    copyToClipboard(textarea.textContent);
}

function copyLinkToClipboard(link)
{
    let url = window.location.host + link;

    copyToClipboard(url);
}

const copyToClipboard = str => {
  const el = document.createElement('textarea');  // Create a <textarea> element
  el.value = str;                                 // Set its value to the string that you want copied
  el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
  el.style.position = 'absolute';                 
  el.style.left = '-9999px';                      // Move outside the screen to make it invisible
  document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
  const selected =            
    document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false;                                    // Mark as false to know no selection existed before
  el.select();                                    // Select the <textarea> content
  document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
  document.body.removeChild(el);                  // Remove the <textarea> element
  if (selected) {                                 // If a selection existed before copying
    document.getSelection().removeAllRanges();    // Unselect everything on the HTML document
    document.getSelection().addRange(selected);   // Restore the original selection
  }
};

function highlightLines()
{
    for (let i = 0; i < highlightedLines.length; i++)
    {
        highlightedLines[i].classList.remove("line-highlight");
    }

    highlightedLines = [];

    let res = location.hash.match(highlightExpr);

    if (res === null)
    {
        return;
    }
    else if (res[1] !== undefined)
    {
        // select the pasty
        let editor = editors[res[1]];
        
        if (res[3] === undefined)
        {
            // single line highlight
            let line = res[2];

            highlightLine(editor, line);
        }
        else
        {
            let startLine = res[2];
            let endLine = res[3];

            for (let i = parseInt(startLine); i <= parseInt(endLine); i++)
            {
                highlightLine(editor, i);
            }
        }
    }
}

function highlightLine(editor, lineNum)
{
    let lineNumElem = editor.getWrapperElement().getElementsByClassName("CodeMirror-linenumber")[lineNum-1];
    let lineElem = lineNumElem.parentElement.parentElement;
    lineElem.classList.add("line-highlight");
    highlightedLines.push(lineElem);
}

function jumpToHighlight()
{
    if (highlightedLines.length === 0)
    {
        return;
    }

    highlightedLines[0].scrollIntoView();
}

/**
 * Figures out whether to use a white or black text colour based on the background colour.
 * The colour should be in a #RRGGBB format, # is needed!
 * Returns true if the text should be white.
 */
function getColor(bgColor)
{
    let red = parseInt(bgColor.substring(1, 3), 16);
    let green = parseInt(bgColor.substring(3, 5), 16);
    let blue = parseInt(bgColor.substring(5, 7), 16);

    return (red * 0.299 + green * 0.587 + blue * 0.114) <= 186;
}
