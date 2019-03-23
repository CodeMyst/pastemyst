import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { getLanguageOptions, LanguageOption } from "api/languageOptions";
import { Dropdown, DropdownItem } from "components/dropdown";

async function initExpiresInDropdown ()
{
    const options: ExpireOption [] = await getExpireOptions ();
    const items: DropdownItem [] = new Array<DropdownItem> (options.length);

    const expiresInDropdown = new Dropdown (document.getElementById ("expires-in").children [0] as HTMLElement,
                                            "expires in:",
                                            false);
    
    for (let i = 0; i < options.length; i++)
    {
        items [i] = new DropdownItem (options [i].value, options [i].pretty);
        expiresInDropdown.addItem (items [i]);
    }

    expiresInDropdown.selectItem (items [0]);
}

async function initLanguageDropdown ()
{
    const options: LanguageOption [] = await getLanguageOptions ();
    const items: DropdownItem [] = new Array<DropdownItem> (options.length);

    const languageDropdown = new Dropdown (document.getElementById ("language").children [0] as HTMLElement,
                                            "language:",
                                            true);
    
    for (let i = 0; i < options.length; i++)
    {
        items [i] = new DropdownItem (options [i].mode, options [i].name);
        languageDropdown.addItem (items [i]);
    }

    languageDropdown.selectItem (items [0]);
}

initExpiresInDropdown ();
initLanguageDropdown ();
