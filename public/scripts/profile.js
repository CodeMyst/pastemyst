window.addEventListener("load", async () =>
{
    for (let i = 0; i < pastes.length; i++) // jshint ignore:line
    {
        let pasteElement = document.querySelectorAll("#profile .pastes .paste")[i];
        let createdAtDate = new Date(pastes[i].createdAt * 1000); // jshint ignore:line

        pasteElement.querySelector(".info .created-at").textContent = "created at: " + createdAtDate.toDateString().toLowerCase();

        const response = await fetch(`/api/time/expiresInToUnixTime?createdAt=${pastes[i].createdAt}&expiresIn=${pastes[i].expiresIn}`, // jshint ignore:line
        {
            headers:
            {
                "Content-Type": "application/json"
            }
        });

        let expiresAt = (await response.json()).result;

        if (expiresAt !== 0)
        {
            let expiresIn = timeDifferenceToString(expiresAt * 1000 - new Date());
            pasteElement.querySelector(".info .expires-in").textContent = "expires in: " + expiresIn;
        }
        else
        {
            let expiresInElem = pasteElement.querySelector(".info .expires-in");
            expiresInElem.parentNode.removeChild(expiresInElem);
        }
    }
});

function timeDifferenceToString(timeDifference)
{
    let resTime;
    let resString;

    if (timeDifference <= 59000)
    {
        resTime = Math.ceil(timeDifference / 1000);
        resString = `${resTime.toString()} seconds`;
    }
    else if (timeDifference <= 3540000)
    {
        resTime = Math.ceil(timeDifference / 60000);
        resString = `${resTime.toString()} minutes`;
    }
    else if (timeDifference <= 82800000)
    {
        resTime = Math.ceil(timeDifference / 3600000);
        resString = `${resTime.toString()} hours`;
    }
    else if (timeDifference <= 518400000)
    {
        resTime = Math.ceil(timeDifference / 86400000);
        resString = `${resTime.toString()} days`;
    }
    else if (timeDifference <= 2419200000)
    {
        resTime = Math.ceil(timeDifference / 604800000);
        resString = `${resTime.toString()} weeks`;
    }
    else if (timeDifference <= 28927800000)
    {
        resTime = Math.ceil(timeDifference / 2629800000);
        resString = `${resTime.toString()} months`;
    }
    else
    {
        resTime = Math.ceil(timeDifference / 31557600000);
        resString = `${resTime.toString()} years`;
    }

    // If the time is just one, remove the s so the time is singular
    if (resTime === 1)
    {
        resString = resString.slice(0, resString.length - 1);
    }

    return resString;
}
