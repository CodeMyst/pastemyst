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
            editor.setOption("mode", langCache.get(langs[i]));
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
                langCache.set(langs[i], lang["mimes"][0]);
            });
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
