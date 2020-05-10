import Dropdown from "../components/dropdown.js";
import { initEditors, addEditor, editors } from "../components/pastyEditor.js";

let expiresInDropdown;

window.addEventListener("load", async() =>
{
    expiresInDropdown = new Dropdown(document.querySelector("#expires-in-dropdown .dropdown"));
    initEditors();

    document.getElementsByClassName("add-editor")[0].addEventListener("click", addEditor);

    document.querySelector(".notice .save").addEventListener("click", () =>
    {
        document.querySelector("input[name=expires-in]").value = expiresInDropdown.value;

        let temps = document.querySelectorAll("input[name=expires-in-temp]");

        for (let i = 0; i < temps.length; i++)
        {
            temps[i].setAttribute("disabled", "");
        }

        for (let i = 0; i < editors.length; i++)
        {
            editors[i].titleInput.name = "title-" + i;

            let dropdownElements= editors[i].rootElement.querySelectorAll(".language-dropdown input[type=radio]");

            for (let d = 0; d < dropdownElements.length; d++)
            {
                dropdownElements[d].setAttribute("disabled", "")
            }

            let textarea = editors[i].rootElement.querySelector("textarea.editor");

            textarea.name = "code-" + i;
            textarea.innerText = editors[i].editor.getValue();
        }

        let langs = document.querySelectorAll("input[name=language]");

        for (let l = 0; l < langs.length; l++)
        {
            langs[l].setAttribute("name", "language-" + l);
            langs[l].value = editors[l].languageDropdown.value;
        }

        let searches = document.querySelectorAll("input[name=search]");

        for (let i = 0; i < searches.length; i++)
        {
            searches[i].setAttribute("disabled", "");
        }

        document.querySelector("form").submit();
    });
});