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

    usernameInput.addEventListener("input", async () =>
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

    document.querySelector(".token-copy").addEventListener("click", () =>
    {
        copyToClipboard(document.querySelector(".token").textContent);
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

const copyToClipboard = str => {
  const el = document.createElement('textarea');  // Create a <textarea> element
  el.value = str;                                 // Set its value to the string that you want copied
  el.setAttribute('readonly', '');                // Make it readonly to be tamper-proof
  el.style.position = 'absolute';                 
  el.style.left = '-9999px';                      // Move outside the screen to make it invisible
  document.body.appendChild(el);                  // Append the <textarea> element to the HTML document
  const selected =            
    document.getSelection().rangeCount > 0 ? document.getSelection().getRangeAt(0) : false;                                    // Mark as false to know no selection existed before
  el.select();                                    // Select the <textarea> content
  document.execCommand('copy');                   // Copy - only works as a result of a user action (e.g. click events)
  document.body.removeChild(el);                  // Remove the <textarea> element
  if (selected) {                                 // If a selection existed before copying
    document.getSelection().removeAllRanges();    // Unselect everything on the HTML document
    document.getSelection().addRange(selected);   // Restore the original selection
  }
};
