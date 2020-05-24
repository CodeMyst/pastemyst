import "./components/navigation.js";

window.addEventListener("load", () =>
{
    document.querySelector("nav .fullwidth").addEventListener("click", toggleFullwidth);

    setFullwidthClasses();
});

function toggleFullwidth()
{
    let fullwidth = localStorage.getItem("fullwidth") === "true";

    localStorage.setItem("fullwidth", !fullwidth);

    setFullwidthClasses();
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