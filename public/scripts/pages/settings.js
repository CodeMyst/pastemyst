import Dropdown from "../components/dropdown.js";
import { usernameHasSpecialChars, usernameStartsWithSymbol, usernameEndsWithSymbol } from "../helpers/username.js";

let msg;
let available;
let originalUsername;
let langDropdown;
let originalLanguage;
let savePressed = false;

window.addEventListener("load", async () =>
{
    langDropdown = new Dropdown(document.querySelector(".default-lang .dropdown"));
    originalLanguage = langDropdown.value;
    const usernameInput = document.querySelector(".settings-block .username input");
    originalUsername = usernameInput.value;
    msg = document.querySelector(".settings-block .username .available");

    await check(usernameInput.value);
    checkUsernameSpecialChars(usernameInput.value);
    checkUsernameSymbolSides(usernameInput.value);
    checkUsernameLength(usernameInput.value);

    usernameInput.addEventListener("input", async () =>
    {
        await check(usernameInput.value);
        checkUsernameSpecialChars(usernameInput.value);
        checkUsernameSymbolSides(usernameInput.value);
        checkUsernameLength(usernameInput.value);
    });

    document.querySelector("button.save").addEventListener("click", () =>
    {
        savePressed = true;

        let langInput = document.querySelector(".default-lang input[name=language]");
    
        langInput.value = langDropdown.value;

        if (available)
        {
            document.querySelector("form").submit();
        }
    });

    let tokenCopyButton = document.querySelector(".token-copy");

    tokenCopyButton.addEventListener("click", () =>
    {
        copyToClipboard(document.querySelector(".token").textContent);
        let originalText = tokenCopyButton.textContent;
        tokenCopyButton.textContent = "copied";
        setTimeout(function(){ tokenCopyButton.textContent = originalText; }, 2000);
    });

    window.addEventListener("beforeunload", (e) =>
    {
        if (checkChange() && !savePressed)
        {
            e.preventDefault();
            e.returnValue = "";
        }
    });
});

function checkChange()
{
    let usernameInput = document.querySelector("input[name=username]");

    if (usernameInput.defaultValue !== usernameInput.value)
    {
        return true;
    }

    let avatarInput = document.querySelector("input[name=avatar]");

    if (avatarInput.files.length !== 0)
    {
        return true;
    }

    if (langDropdown.value !== originalLanguage)
    {
        return true;
    }

    let publicProfileInput = document.querySelector("input[name=publicProfile]");

    if (publicProfileInput.defaultChecked !== publicProfileInput.checked)
    {
        return true;
    }

    return false;
}

function checkUsernameSpecialChars(username)
{
    if (usernameHasSpecialChars(username))
    {
        msg.className = "not-available";
        msg.textContent = "username is invalid (cannot contain special characters)";
        available = false;
    }
}

function checkUsernameSymbolSides(username)
{
    if (usernameStartsWithSymbol(username) || usernameEndsWithSymbol(username))
    {
        msg.className = "not-available";
        msg.textContent = "username is invalid (cannot start or end with symbol)";
        available = false;
    }
}

function checkUsernameLength(username)
{
    if (username.length <= 0)
    {
        msg.className = "not-available";
        msg.textContent = "username is invalid (cannot be empty)";
        available = false;
    }
}

async function check(username)
{
    await fetch(`/api/v2/user/${username}/exists`).then((res) =>
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
