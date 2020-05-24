import "./components/navigation.js";
import { getWordwrap, getFullwidth } from "./helpers/options.js";

window.addEventListener("load", () =>
{
    document.querySelector("nav .fullwidth").addEventListener("click", toggleFullwidth);
    document.querySelector("nav .wordwrap").addEventListener("click", toggleWordwrap);

    setFullwidthClasses();
});

function toggleFullwidth()
{
    let fullwidth = getFullwidth();

    localStorage.setItem("fullwidth", !fullwidth);

    setFullwidthClasses();
}

function toggleWordwrap()
{
    let wordwrap = getWordwrap();

    localStorage.setItem("wordwrap", !wordwrap);

    let editorElements = document.querySelectorAll(".CodeMirror");

    for (let i = 0; i < editorElements.length; i++)
    {
        let editor = editorElements[i].CodeMirror;
        editor.setOption("lineWrapping", !wordwrap);
    }
}

function setFullwidthClasses()
{
    let fullwidth = localStorage.getItem("fullwidth") === "true";
    let container = document.getElementById("container");

    if (fullwidth)
    {
        if (!container.classList.contains("fullwidth"))
        {
            container.classList.add("fullwidth");
        }
    }
    else
    {
        if (container.classList.contains("fullwidth"))
        {
            container.classList.remove("fullwidth");
        }
    }
}