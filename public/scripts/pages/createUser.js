let msg;
let available;

window.addEventListener("load", async () =>
{
    const input = document.querySelector("input[name=username]");
    const form = document.querySelector("form");
    const button = document.querySelector("button");
    msg = document.querySelector(".available");

    await check(input.value);

    input.addEventListener("input", async (e) =>
    {
        await check(input.value);
    });

    button.addEventListener("click", () =>
    {
        if (available)
        {
            form.submit();
        }
    });
});

async function check(username)
{
    await fetch(`/api/user/${username}/exists`).then((res) =>
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
