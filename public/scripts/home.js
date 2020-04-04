import "./navigation.js";
import Dropdown from "./dropdown.js";

class PastyEditor
{
    constructor()
    {
        this.index = 0;
        
        this.rootElement = null;

        this.titleInput = null;
        this.languageDropdown = null;
        this.editor = null;
    }
}

let editors = [];

let expiresInDropdown;

window.addEventListener("load", () =>
{
    // FIXME: issue#55
    if (window.location.hash === "#reload")
    {
        window.location = "/";
    }

    expiresInDropdown = new Dropdown(document.querySelector("#expires-in-dropdown .dropdown"));

    initFirstEditor();

    document.getElementsByClassName("new-pasty-editor")[0].addEventListener("click", () =>
    {
        addEditor();
    });

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

function initFirstEditor()
{
    let editor = new PastyEditor();

    editor.index = 0;

    editor.rootElement = document.getElementsByClassName("pasty-editor")[0];
    editor.titleInput = editor.rootElement.getElementsByClassName("pasty-editor-title")[0];

    let textarea = editor.rootElement.getElementsByClassName("editor")[0];

    // TODO: set initial mode
    editor.editor = CodeMirror.fromTextArea(textarea, // jshint ignore:line
    {
       indentUnit: 4,
       lineNumbers: true,
       mode: "text/plain",
       tabSize: 4,
       theme: "darcula",
       lineWrapping: true
    });

    editor.languageDropdown = setupLanguageDropdown(editor);

    editor.rootElement.getElementsByClassName("pasty-editor-delete")[0].addEventListener("click", () =>
    {
        removeEditor(editor);
    });

    editors.push(editor);
}

function addEditor()
{
    let editor = new PastyEditor();

    editor.index = editors.length;

    let clone = editors[editors.length - 1].rootElement.cloneNode(true);

    editor.rootElement = clone;

    clone.getElementsByClassName("CodeMirror")[0].remove();

    let titleInput = clone.getElementsByClassName("pasty-editor-title")[0];

    editor.titleInput = titleInput;
    editor.titleInput.value = "";

    let textArea = clone.getElementsByClassName("editor")[0];

    // TODO: set initial mode
    editor.editor = CodeMirror.fromTextArea(textArea, // jshint ignore:line
    {
        indentUnit: 4,
        lineNumbers: true,
        mode: "text/plain",
        tabSize: 4,
        theme: "darcula",
        lineWrapping: true
    });

    document.getElementById("pasty-editors").appendChild(clone);

    editors.push(editor);

    setupDeleteButton(editor);

    if (editors.length === 2)
    {
        setupDeleteButton(editors[0]);
    }

    editor.languageDropdown = setupLanguageDropdown(editor);

    editor.rootElement.getElementsByClassName("pasty-editor-delete")[0].addEventListener("click", () =>
    {
        removeEditor(editor);
    });

    editor.editor.refresh();
    editor.editor.focus();
}

function setupLanguageDropdown(editor)
{
    let language = new Dropdown(editor.rootElement.querySelector("#language-dropdown .dropdown"));

    language.resetValue();

    language.onValueChange = (v) =>
    {
        // using 1 and 2 because the first index is the name
        let s = v.split(",");
        setMode(editor.editor, s[1], s[2]);
    };

    // using 1 and 2 because the first index is the name
    let l = language.value.split(",");
    setMode(editor.editor, l[1], l[2]);

    return language;
}

function removeEditor(editor)
{
    if (editors.length === 1)
    {
        return;
    }

    editor.rootElement.remove();

    editors.splice(editor.index, 1);

    if (editors.length === 1)
    {
        removeDeleteButton(editors[0]);
    }

    for (let i = 0; i < editors.length; i++)
    {
        editors[i].index = i;
    }
}

function setupDeleteButton(editor)
{
    editor.rootElement.getElementsByClassName("pasty-editor-delete")[0].style.display = "initial";
    let titleInput = editor.rootElement.getElementsByClassName("pasty-editor-title")[0];
    titleInput.style.borderTopLeftRadius = "0";
}

function removeDeleteButton(editor)
{
    editor.rootElement.getElementsByClassName("pasty-editor-delete")[0].style.display = "none";
    let titleInput = editor.rootElement.getElementsByClassName("pasty-editor-title")[0];
    titleInput.style.borderTopLeftRadius = "0.3rem";
}

function setMode(editor, mode, mime)
{
    if (mode === "null")
    {
        editor.setOption("mode", "text/plain");
        return;
    }

    import(`./libs/codemirror/${mode}/${mode}.js`).then(() => // jshint ignore:line
    {
        editor.setOption("mode", mime);
    });
}

async function createPaste()
{
    // TODO: add isPrivate field
    
    let form = document.getElementById("paste-create-form-hidden");

    form.querySelector("input[name=title]").value = document.querySelector(`.paste-options input[name="title"]`).value;
    form.querySelector("input[name=expiresIn]").value = expiresInDropdown.value;
    form.querySelector("input[name=isPrivate]").checked = false;

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
