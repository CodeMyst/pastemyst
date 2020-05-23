import Dropdown from "../components/dropdown.js";
import { initEditors, addEditor, editors } from "../components/pastyEditor.js";

let expiresInDropdown;

window.addEventListener("load", () =>
{
    // FIXME: issue#55
    if (window.location.hash === "#reload")
    {
        window.location = "/";
    }

    expiresInDropdown = new Dropdown(document.querySelector("#expires-in-dropdown .dropdown"));
    expiresInDropdown.resetValue();

    initEditors();

    document.getElementsByClassName("add-editor")[0].addEventListener("click", addEditor);

    let pasteOptionsBottomObserver = new IntersectionObserver((e) =>
    {
        if (e[0].intersectionRatio === 0)
        {
            document.querySelector(".paste-options-bottom").classList.add("paste-options-bottom-sticky");
        }
        else if (e[0].intersectionRatio === 1)
        {
            document.querySelector(".paste-options-bottom").classList.remove("paste-options-bottom-sticky");
        }
    }, { threshold: [0, 1] });

    pasteOptionsBottomObserver.observe(document.querySelector(".paste-options-bottom-1px"));

    document.getElementById("create-paste").addEventListener("click", async () => await createPaste());
});

async function createPaste()
{
    // TODO: add isPrivate field
    
    let form = document.getElementById("paste-create-form-hidden");

    form.querySelector("input[name=title]").value = document.querySelector(`.paste-options input[name="title"]`).value;
    form.querySelector("input[name=expiresIn]").value = expiresInDropdown.value;
    form.querySelector("input[name=isPrivate]").checked = false;
    form.querySelector("input[name=isPublic]").checked = document.querySelector(".paste-options-bottom-options input#public").checked;

    const pasties = [];

    for (let i = 0; i < editors.length; i++)
    {
        let pasty =
        {
            title: editors[i].titleInput.value,
            language: editors[i].languageDropdown.value.split(",")[0],
            code: editors[i].editor.getValue()
        };

        pasties.push(pasty);
    }

    form.querySelector("input[name=pasties]").value = JSON.stringify(pasties);

    form.submit();
}
