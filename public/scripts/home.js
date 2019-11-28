import "./navigation.js";
import Dropdown from "./dropdown.js";

var CodeMirror;

window.addEventListener ("load", () =>
{
    new Dropdown ("#expires-in-dropdown .dropdown");
    new Dropdown ("#language-dropdown .dropdown");

    let editorTextArea = document.querySelector (".pasty-editor .editor");
    CodeMirror.fromTextArea (editorTextArea,
    {
       theme: "darcula",
       lineNumbers: true 
    });
});
