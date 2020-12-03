import { getWordwrap, getTheme } from "../helpers/options.js";

let langCache = new Map();

window.addEventListener("load", async () =>
{
    let editedAtElements = document.querySelectorAll(".editedAt");

    for (let i = 0; i < editedAtElements.length; i++)
    {
        let dateUnix = editedAtElements[i].innerHTML;
        let date = new Date(dateUnix * 1000);
        let dateText = date.toString().toLowerCase();
        dateText = dateText.substring(0, dateText.indexOf("(")-1);
        dateText = " " + dateText;
        editedAtElements[i].textContent = dateText;
    }

    let diffTextareas = document.querySelectorAll("textarea.diff");

    for (let i = 0; i < diffTextareas.length; i++)
    {
        CodeMirror.fromTextArea(diffTextareas[i], // jshint ignore:line
        {
            indentUnit: 4,
            lineNumbers: true,
            mode: "text/x-diff",
            tabSize: 4,
            theme: getTheme(),
            lineWrapping: getWordwrap(),
            readOnly: true,
            extraKeys:
            {
                Tab: (cm) => cm.execCommand("insertSoftTab")
            }
        });
    }

    let addedTextareas = document.querySelectorAll("textarea.added");

    for (let i = 0; i < addedTextareas.length; i++)
    {
        let editor = CodeMirror.fromTextArea(addedTextareas[i], // jshint ignore:line
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

        let lang = addedTextareas[i].parentElement.parentElement.querySelector("span.lang").textContent;
        let langMime = await loadLanguage(lang);
        let langColor;

        editor.setOption("mode", langMime);

        langColor = langCache.get(lang)[1];

        if (langColor)
        {
            let langTextElem = addedTextareas[i].parentElement.parentElement.querySelector("span.lang");

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
    }

    let copyLinkButton = document.querySelector(".paste-header .copy-link");
    let copyLink = copyLinkButton.getAttribute("href");
    copyLinkButton.addEventListener("click", () => copyLinkToClipboard(copyLinkButton, copyLink));
    copyLinkButton.removeAttribute("href");

    let copyLinkEditButton = document.querySelector(".paste-header .copy-link-edit");
    let copyEditLink = copyLinkEditButton.getAttribute("href");
    copyLinkEditButton.addEventListener("click", () => copyLinkToClipboard(copyLinkEditButton, copyEditLink));
    copyLinkEditButton.removeAttribute("href");

    const embedScriptCopy = document.querySelector(".embed-script-copy");
    const embedScript = document.querySelector(".embed-script");
    if (embedScriptCopy)
    {
        embedScriptCopy.addEventListener("click", () =>
        {
            copyToClipboard(embedScript.value);
            let textElem = embedScriptCopy.querySelector(".tooltip-text");
            let originalText = textElem.textContent;
            textElem.textContent = "copied";
            setTimeout(function(){ textElem.textContent = originalText; }, 2000);
        });
    }
});

function copyLinkToClipboard(button, link)
{
    let url = window.location.protocol + "//" + window.location.host + link;

    copyToClipboard(url);

    let textElem = button.querySelector(".tooltip-text");

    let originalText = textElem.textContent;

    textElem.textContent = "copied";

    setTimeout(function(){ textElem.textContent = originalText; }, 2000);
}

async function loadLanguage(lang)
{
    if (lang === "HTML")
    {
        await loadLanguage("XML");
    }

    if (lang === "JSX")
    {
        await loadLanguage("XML");
        await loadLanguage("JavaScript");
    }

    let langMime;

    if (langCache.has(lang)) // jshint ignore:line
    {
        langMime = langCache.get(lang)[0]; // jshint ignore:line
    }
    else
    {
        let res = await fetch(`/api/v2/data/language?name=${encodeURIComponent(lang)}`, // jshint ignore:line
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
                langCache.set(lang, [langData.mimes[0], langData.color]); // jshint ignore:line
            });
        }
        else
        {
            langMime = "text/plain";
            langCache.set(lang, ["text/plain", "#ffffff"]); // jshint ignore:line
        }
    }

    return langMime;
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
