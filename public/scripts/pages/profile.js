import { timeDifferenceToString } from "../helpers/time.js";

window.addEventListener("load", async () =>
{
    for (let i = 0; i < pastes.length; i++) // jshint ignore:line
    {
        let pasteElement = document.querySelectorAll("#profile .pastes .paste")[i];
        let createdAtDate = new Date(pastes[i].createdAt * 1000); // jshint ignore:line

        pasteElement.querySelector(".info .created-at").textContent = "created at: " + createdAtDate.toDateString().toLowerCase();

        // TODO: this can be optimized, the pastes now hold information where they will get deleted
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
