import { timeDifferenceToString } from "./time.js";

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
            theme: "darcula",
            lineWrapping: true,
            readOnly: "nocursor"
        });

        let langMime;
        let langColor;

        if (langCache.has(langs[i])) // jshint ignore:line
        {
            langMime = langCache.get(langs[i])[0]; // jshint ignore:line
        }
        else
        {
            let res = await fetch(`/api/data/language?name=${encodeURIComponent(langs[i])}`, // jshint ignore:line
            {
                headers:
                {
                    "Content-Type": "application/json"
                }
            });

            let langData = await res.json();

            if (langData.mode !== "null")
            {
                await import(`./libs/codemirror/${langData.mode}/${langData.mode}.js`).then(() => // jshint ignore:line
                {
                    langMime = langData.mimes[0];
                });
            }

            langCache.set(langs[i], [langData.mimes[0], langData.color]); // jshint ignore:line
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
    }

    let createdAtDate = new Date(createdAt * 1000); // jshint ignore:line

    document.querySelector(".paste-meta .created-at .value").textContent = " " + createdAtDate.toString().toLowerCase();

    const response = await fetch(`/api/time/expiresInToUnixTime?createdAt=${createdAt}&expiresIn=${expiresIn}`, // jshint ignore:line
    {
        headers:
        {
            "Content-Type": "application/json"
        }
    });

    let expiresAt = (await response.json()).result;

    if (expiresAt !== 0)
    {
        let expiresIn = timeDifferenceToString(expiresAt * 1000 - new Date());
        document.querySelector(".paste-meta .expires-in .value").textContent = " " + expiresIn;
    }
    else
    {
        let expiresInElem = document.querySelector(".paste-meta .expires-in");
        expiresInElem.parentNode.removeChild(expiresInElem);
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
