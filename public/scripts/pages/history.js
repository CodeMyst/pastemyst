window.addEventListener("load", () =>
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

    let textareas = document.querySelectorAll("textarea");

    for (let i = 0; i < textareas.length; i++)
    {
        let editor = CodeMirror.fromTextArea(textareas[i], // jshint ignore:line
        {
            indentUnit: 4,
            lineNumbers: true,
            mode: "text/x-diff",
            tabSize: 4,
            theme: "darcula",
            lineWrapping: true,
            readOnly: true
        });
    }
});