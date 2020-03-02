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

        if (langCache.has(langs[i]))
        {
            editor.setOption("mode", langCache.get(langs[i])[0]);
        }
        else
        {
            let res = await fetch(`/api/data/language?name=${langs[i]}`,
            {
                headers:
                {
                    "Content-Type": "application/json"
                }
            });
    
            let lang = await res.json();
    
            await import(`./libs/codemirror/${lang["mode"]}/${lang["mode"]}.js`).then(() =>
            {
                editor.setOption("mode", lang["mimes"][0]);
            });

            langCache.set(langs[i], [lang["mimes"][0], lang["color"]]);
        }

        if (langCache.get(langs[i])[1])
        {
            let langText = textareas[i].closest(".pasty").getElementsByClassName("lang")[0];
            let color = langCache.get(langs[i])[1];

            langText.style.backgroundColor = color;

            if (getColor(color))
            {
                langText.style.color = "white";
            }
            else
            {
                langText.style.color = "black";
            }
        }
    }

    let createdAtDate = new Date(createdAt * 1000);

    document.querySelector(".paste-meta .created-at .value").textContent = " " + createdAtDate.toString().toLowerCase();

    const response = await fetch(`/api/time/expiresInToUnixTime?createdAt=${createdAt}&expiresIn=${expiresIn}`,
    {
        headers:
        {
            "Content-Type": "application/json"
        }
    });

    let expiresAt = (await response.json())["result"];

    if (expiresAt !== 0)
    {
        document.querySelector(".paste-meta .expires-at .value").textContent = " " + new Date(expiresAt * 1000).toString().toLowerCase();
    }
    else
    {
        document.querySelector(".paste-meta .expires-at .highlight").textContent = "expires in:";
        document.querySelector(".paste-meta .expires-at .value").textContent = " never";
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
