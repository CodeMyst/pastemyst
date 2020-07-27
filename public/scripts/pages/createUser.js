import { usernameHasSpecialChars } from "../helpers/username.js";

let msg;
let available;

window.addEventListener("load", async () =>
{
    const input = document.querySelector("input[name=username]");
    const form = document.querySelector("form");
    const button = document.querySelector("button");
    msg = document.querySelector(".available");

    await check(input.value);
    checkUsernameSpecialChars(input.value);

    input.addEventListener("input", async () =>
    {
        await check(input.value);
        checkUsernameSpecialChars(input.value);
    });

    button.addEventListener("click", () =>
    {
        if (available)
        {
            form.submit();
        }
    });
});

function checkUsernameSpecialChars(username)
{
    if (usernameHasSpecialChars(username))
    {
        msg.className = "not-valid";
        msg.textContent = "username is invalid (cannot contain special characters)";
        available = false;
    }
}

async function check(username)
{
    await fetch(`/api/v2/user/${username}/exists`).then((res) =>
    {
        if (res.ok)
        {
            msg.className = "not-available";
            msg.textContent = "username not available";
            available = false;
        }
        else
        {
            msg.className = "available";
            msg.textContent = "username available";
            available = true;
        }
    });
}
