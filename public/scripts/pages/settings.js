import Dropdown from "../components/dropdown.js";

let msg;
let available;
let originalUsername;

window.addEventListener("load", async () =>
{
    let langDropdown = new Dropdown(document.querySelector(".default-lang .dropdown"));
    const usernameInput = document.querySelector(".settings-block .username input");
    originalUsername = usernameInput.value;
    msg = document.querySelector(".settings-block .username .available");

    await check(usernameInput.value);

    usernameInput.addEventListener("input", async (e) =>
    {
        await check(usernameInput.value);
    });

    document.querySelector("button.save").addEventListener("click", () =>
    {
        let langInput = document.querySelector(".default-lang input[name=language]");
    
        langInput.value = langDropdown.value;

        if (available)
        {
            document.querySelector("form").submit();
        }
    });
});

async function check(username)
{
    await fetch(`/api/user/${username}/exists`).then((res) =>
    {
        if (!res.ok || username.toLowerCase() === originalUsername.toLowerCase())
        {
            msg.className = "available";
            msg.textContent = "username available";
            available = true;
        }
        else
        {
            msg.className = "not-available";
            msg.textContent = "username not available";
            available = false;
        }
    });
}
