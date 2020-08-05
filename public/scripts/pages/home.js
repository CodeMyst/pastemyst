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
    anonLabel = document.querySelector("label[for=anonymous]");
    publicInput = document.querySelector("input#public");
    publicLabel = document.querySelector("label[for=public]");
    privateInput = document.querySelector("input#private");
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

    if (privateInput)
    {
        checkOptions();

        anonInput.addEventListener("click", () =>
        {
            checkOptions();
        });

        privateInput.addEventListener("click", () =>
        {
            checkOptions();
        });
    }

    const encryptCheckbox = document.getElementById("encrypt");
    const encryptOptions = document.getElementById("encrypt-options");

    if (encryptCheckbox.checked)
    {
        encryptOptions.classList.remove("hidden");
    }
    else
    {
        encryptOptions.classList.add("hidden");
    }

    encryptCheckbox.addEventListener("click", () =>
    {
        encryptOptions.classList.toggle("hidden");
    });
});

function disableInput(input, label)
{
    input.checked = false;
    input.disabled = true;
    label.classList = "disabled";
}

function enableInput(input, label)
{
    input.disabled = false;
    label.classList = "";
}

function checkOptions()
{
    if (privateInput.checked)
    {
        disableInput(publicInput, publicLabel);
        disableInput(anonInput, anonLabel);
    }
    else if (anonInput.checked)
    {
        disableInput(publicInput, publicLabel);
        disableInput(privateInput, privateLabel);
    }
    else
    {
        enableInput(publicInput, publicLabel);
        enableInput(privateInput, privateLabel);
        enableInput(anonInput, anonLabel);
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
    let form = document.getElementById("paste-create-form-hidden");

    form.querySelector("input[name=title]").value = document.querySelector(`.paste-options input[name="title"]`).value;
    form.querySelector("input[name=expiresIn]").value = expiresInDropdown.value;
    if (privateInput)
    {
        form.querySelector("input[name=isPrivate]").checked = privateInput.checked;
        form.querySelector("input[name=isPublic]").checked = publicInput.checked;
        form.querySelector("input[name=isAnonymous]").checked = anonInput.checked;
    }

    let tagsinput = document.querySelector(".paste-options input[name=tags]");

    if (tagsinput)
    {
        form.querySelector("input[name=tags]").value = tagsinput.value;
    }

    form.querySelector("input[name=encrypt]").checked = document.getElementById("encrypt").checked;
    form.querySelector("input[name=password]").value = document.getElementById("encrypt-password").value;

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
