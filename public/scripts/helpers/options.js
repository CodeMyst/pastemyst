export function getWordwrap()
{
    let wordwrap = localStorage.getItem("wordwrap");

    if (wordwrap === null)
    {
        return true;
    }
    else
    {
        wordwrap = localStorage.getItem("wordwrap") === "true";
        return wordwrap;
    }
}

export function getFullwidth()
{
    let fullwidth = localStorage.getItem("fullwidth") === "true";

    return fullwidth;
}

export function getTheme()
{
    return localStorage.getItem("theme");
}
