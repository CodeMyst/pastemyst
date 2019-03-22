import { Dropdown, DropdownItem } from "components/dropdown";

const item1: DropdownItem = new DropdownItem ("never", "never");
const item2: DropdownItem = new DropdownItem ("1h", "1 hour");
const item3: DropdownItem = new DropdownItem ("2h", "2 hours");
const item4: DropdownItem = new DropdownItem ("1d", "1 day");

const expiresInDropdown = new Dropdown (document.getElementById ("expires-in").children [0] as HTMLElement);
expiresInDropdown.addItem (item1);
expiresInDropdown.addItem (item2);
expiresInDropdown.addItem (item3);
expiresInDropdown.addItem (item4);
expiresInDropdown.selectItem (item3);
