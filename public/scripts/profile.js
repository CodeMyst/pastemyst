let dates = document.getElementsByClassName ('createdAt');

for (let i = 0; i < dates.length; i++)
{
    let span = dates [i].getElementsByTagName ('span') [0];
    let date = new Date (span.innerText * 1000);
    span.innerText = date.toLocaleString ();
}
