import Dropdown from "../components/dropdown.js";
import { initEditors, addEditor, editors } from "../components/pastyEditor.js";

let expiresInDropdown;
let createPressed = false;
let anonInput;
let publicInput;
let privateInput;
let anonLabel;
let publicLabel;
let privateLabel;

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

    anonInput = document.querySelector("input#anonymous");
    publicInput = document.querySelector("input#public");
    privateInput = document.querySelector("input#private");
    anonLabel = document.querySelector("label[for=anonymous]");
    publicLabel = document.querySelector("label[for=public]");
    privateLabel = document.querySelector("label[for=private]");

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

    window.addEventListener("beforeunload", (e) =>
    {
        if (checkChange() && !createPressed)
        {
            e.preventDefault();
            e.returnValue = "";
        }
    });

    if (anonInput)
    {
        checkAnon();

        anonInput.addEventListener("click", () =>
        {
            checkAnon();
        });
    }
});

function checkAnon()
{
    if (anonInput.checked)
    {
        privateInput.checked = false;
        publicInput.checked = false;
        privateInput.disabled = true;
        publicInput.disabled = true;
        privateLabel.classList = "disabled";
        publicLabel.classList = "disabled";
    }
    else
    {
        privateInput.disabled = false;
        publicInput.disabled = false;
        privateLabel.classList = "";
        publicLabel.classList = "";
    }
}

function checkChange()
{
    if (document.querySelector(`.paste-options input[name="title"]`).value !== "")
    {
        return true;
    }

    let tagsinput = document.querySelector(".paste-options input[name=tags]");

    if (tagsinput)
    {
        if (tagsinput.value !== "")
        {
            return true;
        }
    }

    for (let i = 0; i < editors.length; i++)
    {
        if (editors[i].titleInput.value !== "")
        {
            return true;
        }

        if (editors[i].editor.getValue() !== "")
        {
            return true;
        }
    }

    return false;
}

async function createPaste()
{
    // TODO: add isPrivate field
    
    let form = document.getElementById("paste-create-form-hidden");

    form.querySelector("input[name=title]").value = document.querySelector(`.paste-options input[name="title"]`).value;
    form.querySelector("input[name=expiresIn]").value = expiresInDropdown.value;
    form.querySelector("input[name=isPrivate]").checked = false;
    form.querySelector("input[name=isPublic]").checked = publicInput.checked;
    if (anonInput)
    {
        form.querySelector("input[name=isAnonymous]").checked = anonInput.checked;
    }

    let tagsinput = document.querySelector(".paste-options input[name=tags]");

    if (tagsinput)
    {
        form.querySelector("input[name=tags]").value = tagsinput.value;
    }

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
    
    createPressed = true;

    form.submit();
}
