window.addEventListener("load", () =>
{
    let editedAtElements = document.querySelectorAll(".editedAt");

    for (let i = 0; i < editedAtElements.length; i++)
    {
        let dateUnix = editedAtElements[i].innerHTML;
        let date = new Date(dateUnix * 1000);
        editedAtElements[i].innerHTML = date.toString().toLowerCase();
    }
});