window.addEventListener("load", () =>
{
    let editedAtElements = document.querySelectorAll(".editedAt");

    for (let i = 0; i < editedAtElements.length; i++)
    {
        let dateUnix = editedAtElements[i].innerHTML;
        let date = new Date(dateUnix * 1000);
        let dateText = date.toString().toLowerCase();
        dateText = dateText.substring(0, dateText.indexOf("(")-1);
        dateText = " " + dateText;
        editedAtElements[i].textContent = dateText;
    }
});