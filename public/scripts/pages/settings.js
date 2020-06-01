import Dropdown from "../components/dropdown.js";

window.addEventListener("load", () =>
{
    let langDropdown = new Dropdown(document.querySelector(".default-lang .dropdown"));

    document.querySelector("input.save").addEventListener("click", () =>
    {
        let langInput = document.querySelector(".default-lang input[name=language]");
    
        langInput.value = langDropdown.value;

        document.querySelector("form").submit();
    });
});