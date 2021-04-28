import Dropdown from "../components/dropdown.js";
import { PastyEditor } from "../data/editor.js";
import { getWordwrap, getTheme } from "../helpers/options.js";

export let editors = [];

export function initEditors()
{
    let editorElements = document.getElementsByClassName("pasty-editor");

    for (let i = 0; i < editorElements.length; i++)
    {
        let editor = new PastyEditor();

        editor.index = i;

        editor.rootElement = editorElements[i];
        editor.titleInput = editor.rootElement.getElementsByClassName("pasty-editor-title")[0];

        let textarea = editor.rootElement.getElementsByClassName("editor")[0];

        editor.editor = CodeMirror.fromTextArea(textarea, // jshint ignore:line
        {
            indentUnit: 4,
            lineNumbers: true,
            mode: "text/plain",
            tabSize: 4,
            theme: getTheme(),
            lineWrapping: getWordwrap(),
            dragDrop: false,
            extraKeys:
            {
                Tab: (cm) => cm.execCommand("insertSoftTab")
            }
        });

        editor.languageDropdown = setupLanguageDropdown(editor);

        editor.rootElement.getElementsByClassName("pasty-editor-delete")[0].addEventListener("click", () => removeEditor(editor)); // jshint ignore:line

        editors.push(editor);
    }

    if (editors.length > 1)
    {
        for (let i = 0; i < editors.length; i++)
        {
            setupDeleteButton(editors[i]);
        }
    }

    handleMoveButtons();
}

export function addEditor()
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
    textArea.innerText = "";

    let idInput = clone.querySelector("input[name=id]");
    idInput.setAttribute("value", "");

    editor.editor = CodeMirror.fromTextArea(textArea, // jshint ignore:line
    {
        indentUnit: 4,
        lineNumbers: true,
        mode: "text/plain",
        tabSize: 4,
        theme: getTheme(),
        lineWrapping: getWordwrap(),
        dragDrop: false,
        extraKeys:
        {
            Tab: (cm) => cm.execCommand("insertSoftTab")
        }
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

    setMode(editor.editor, "null", "null");

    handleMoveButtons();
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

    handleMoveButtons();
}

function handleMoveButtons()
{
    if (editors.length < 2)
    {
        removeMoveUpButton(editors[0]);
        removeMoveDownButton(editors[0]);
        return;
    }

    setupMoveDownButton(editors[0]);
    removeMoveUpButton(editors[0]);

    editors[0].rootElement.getElementsByClassName("pasty-editor-movedown")[0].addEventListener("click", () => swapEditors(0, 1));

    for (let i = 1; i < editors.length - 1; i++)
    {
        setupMoveUpButton(editors[i]);
        setupMoveDownButton(editors[i]);

        editors[i].rootElement.getElementsByClassName("pasty-editor-moveup")[0].addEventListener("click", () => swapEditors(i-1,i)); // jshint ignore:line
        editors[i].rootElement.getElementsByClassName("pasty-editor-movedown")[0].addEventListener("click", () => swapEditors(i,i+1)); // jshint ignore:line
    }

    setupMoveUpButton(editors[editors.length-1]);
    removeMoveDownButton(editors[editors.length-1]);

    editors[editors.length-1].rootElement.getElementsByClassName("pasty-editor-moveup")[0].addEventListener("click", () => swapEditors(editors.length-2, editors.length-1));
}

function swapEditors(a, b)
{
    editors[a].rootElement.parentNode.insertBefore(editors[a].rootElement.nextElementSibling, editors[a].rootElement);
    let tmp = editors[a];
    editors[a] = editors[b];
    editors[b] = tmp;
    editors[a].index = a;
    editors[b].index = b;
    handleMoveButtons();
}

function setupMoveUpButton(editor)
{
    let elm = editor.rootElement.getElementsByClassName("pasty-editor-moveup")[0];
    elm.style.display = "initial";
    elm.replaceWith(elm.cloneNode(true));
}

function removeMoveUpButton(editor)
{
    editor.rootElement.getElementsByClassName("pasty-editor-moveup")[0].style.display = "none";
}

function setupMoveDownButton(editor)
{
    let elm = editor.rootElement.getElementsByClassName("pasty-editor-movedown")[0];
    elm.style.display = "initial";
    elm.replaceWith(elm.cloneNode(true));
}

function removeMoveDownButton(editor)
{
    editor.rootElement.getElementsByClassName("pasty-editor-movedown")[0].style.display = "none";
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

function setupLanguageDropdown(editor)
{
    let languageDropdown = new Dropdown(editor.rootElement.querySelector(".language-dropdown .dropdown"));

    languageDropdown.resetValue();

    languageDropdown.onValueChange = (v) =>
    {
        // using 1 and 2 because the first index is the name
        let s = v.split(",");
        setMode(editor.editor, s[1], s[2]);
    };

    let l = languageDropdown.value.split(",");
    setMode(editor.editor, l[1], l[2]);

    return languageDropdown;
}

function setMode(editor, mode, mime)
{
    if (mode === "null")
    {
        editor.setOption("mode", "text/plain");
        return;
    }

    if (mode === "htmlmixed")
    {
        import("../libs/codemirror/xml/xml.js"); // jshint ignore:line
    }

    if (mode === "jsx")
    {
        import("../libs/codemirror/xml/xml.js"); // jshint ignore:line
        import("../libs/codemirror/javascript/javascript.js"); // jshint ignore:line
    }

    import(`../libs/codemirror/${mode}/${mode}.js`).then(() => // jshint ignore:line
    {
        editor.setOption("mode", mime);
    });
}
