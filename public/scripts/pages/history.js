import { getWordwrap, getTheme } from "../helpers/options.js";

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

    let langCache = new Map();

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
        let langMime;
        let langColor;

        if (langCache.has(lang))
        {
            langMime = langCache.get(lang)[0];
        }
        else
        {
            let res = await fetch(`/api/data/language?name=${encodeURIComponent(lang)}`,
            {
                headers:
                {
                    "Content-Type": "application/json"
                }
            });

            let langData = await  res.json();

            if (langData.mode !== "null")
            {
                await import(`../libs/codemirror/${langData.mode}/${langData.mode}.js`).then(() => // jshint ignore:line
                {
                    langMime = langData.mimes[0];
                });
            }

            langCache.set(lang, [langData.mimes[0], langData.color]);
        }

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
});

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
