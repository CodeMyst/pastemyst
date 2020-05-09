import Dropdown from "../components/dropdown.js";
import { initEditors, addEditor } from "../components/pastyEditor.js";

let expiresInDropdown;

window.addEventListener("load", async() =>
{
    expiresInDropdown = new Dropdown(document.querySelector("#expires-in-dropdown .dropdown"));
    initEditors();

    document.getElementsByClassName("add-editor")[0].addEventListener("click", addEditor);
});