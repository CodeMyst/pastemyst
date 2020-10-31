window.addEventListener("load", () =>
{
    //removeNavigationDelimiters();
});

window.addEventListener("resize", () =>
{
    //removeNavigationDelimiters();
});

/**
 * Removes the "-" delimiter from the navigation so it wouldn't looks like this on smaller screens:
 * ```
 * home - login - github - api -
 * about - donate
 * ```
 * 
 * But instead will look like this:
 * ```
 * home - login - github - api
 * about - donate
 * ```
 */
function removeNavigationDelimiters()
{
    let elements = document.getElementsByTagName("nav")[0].getElementsByTagName("li");

    for (let i = 0; i < elements.length - 1; i++)
    {
        elements[i].classList.remove("no-delimiter");
    }

    for (let i = 0; i < elements.length - 1; i++)
    {
        let currentRect = elements[i].getBoundingClientRect();
        let nextRect = elements[i + 1].getBoundingClientRect();

        if (currentRect.top !== nextRect.top)
        {
            elements[i].classList.add("no-delimiter");
        }
    }
}
