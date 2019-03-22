import { ExpireOption, getExpireOptions } from "api/expireOptions";
import { Dropdown, DropdownItem } from "components/dropdown";

async function initExpiresInDropdown ()
{
    const options: ExpireOption [] = await getExpireOptions ();
    const items: DropdownItem [] = new Array<DropdownItem> (options.length);

    const expiresInDropdown = new Dropdown (document.getElementById ("expires-in").children [0] as HTMLElement, false);
    
    for (let i = 0; i < options.length; i++)
    {
        items [i] = new DropdownItem (options [i].value, options [i].pretty);
        expiresInDropdown.addItem (items [i]);
    }

    expiresInDropdown.selectItem (items [0]);
}

initExpiresInDropdown ();
