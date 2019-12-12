import "./navigation.js";
import Dropdown from "./dropdown.js";

let editor;

window.addEventListener ("load", () =>
{
    new Dropdown ("#expires-in-dropdown .dropdown");
    let language = new Dropdown ("#language-dropdown .dropdown");

    language.onValueChange = (v) =>
    {
        // using 1 and 2 because the first index is the name
        let s = v.split (",");
        setMode (s [1], s [2]);
    };

    let editorTextArea = document.querySelector (".pasty-editor .editor");
    editor = CodeMirror.fromTextArea (editorTextArea, // jshint ignore:line
    {
       theme: "darcula",
       lineNumbers: true 
    });

    // using 1 and 2 because the first index is the name
    let l = language.value.split (",");
    setMode (l [1], l [2]);
});

function setMode (mode, mime)
{
    if (mode === "null")
    {
        editor.setOption ("mode", "text/plain");
        return;
    }

    import (`./libs/codemirror/${mode}/${mode}.js`).then (() => // jshint ignore:line
    {
        editor.setOption ("mode", mime);
    });
}
