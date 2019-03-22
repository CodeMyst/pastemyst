export class Dropdown
{
    private dropdown: HTMLElement;
    private clickable: HTMLElement;
    private selectable: HTMLElement;
    private search: HTMLInputElement;
    private notFound: HTMLElement;
    private selectedText: HTMLElement;
    private visible: boolean;
    private items: Map<DropdownItem, HTMLElement>;
    private selectedItemElement: [DropdownItem, HTMLElement];

    public selectedItem: DropdownItem;

    constructor (dropdown: HTMLElement, hasSearch: boolean)
    {
        this.dropdown = dropdown;
        this.clickable = this.dropdown.getElementsByClassName ("clickable") [0] as HTMLElement;
        this.selectable = this.dropdown.getElementsByClassName ("selectable") [0] as HTMLElement;
        this.selectedText = this.clickable.getElementsByClassName ("selected") [0] as HTMLElement;
        this.search = this.dropdown.getElementsByClassName ("search") [0] as HTMLInputElement;
        if (!hasSearch)
        {
            this.search.remove ();
        }
        this.notFound = this.selectable.getElementsByClassName ("not-found") [0] as HTMLElement;

        this.clickable.addEventListener ("click", () => this.toggleVisible ());

        this.search.addEventListener ("input", () => this.onSearch ());

        this.items = new Map<DropdownItem, HTMLElement> ();

        window.addEventListener ("click", (evt) => 
        {
            if (!this.visible)
            {
                return;
            }

            if (!this.dropdown.contains (evt.target as Node))
            {
                this.toggleVisible ();
            }
        });
    }

    public addItem (item: DropdownItem): void
    {
        let itemNode: HTMLDivElement = document.createElement ("div");
        itemNode.classList.add ("item");
        itemNode.innerText = item.prettyValue;
        itemNode.addEventListener ("click", (evt) => this._selectItem ([item, evt.target as HTMLElement]));
        this.selectable.getElementsByClassName ("items") [0].appendChild (itemNode);

        this.items.set (item, itemNode);
    }

    private hide (): void
    {
        this.dropdown.classList.add ("hidden");
        this.visible = false;
    }

    private show (): void
    {
        this.dropdown.classList.remove ("hidden");
        this.visible = true;
    }

    private toggleVisible (): void
    {
        if (this.visible)
        {
            this.hide ();
        }
        else
        {
            this.show ();
        }
    }

    private _selectItem (item: [DropdownItem, HTMLElement]): void
    {
        if (this.selectedItemElement !== undefined)
        {
            this.selectedItemElement [1].classList.remove ("selected");
        }
        this.selectedItemElement = item;
        this.selectedItemElement [1].classList.add ("selected");
        this.selectedText.innerText = item [0].prettyValue;
        this.selectedItem = item [0];
        this.hide ();
    }

    public selectItem (item: DropdownItem): void
    {
        this._selectItem ([item, this.items.get (item)]);
    }

    private onSearch (): void
    {
        const searchValue: string = this.search.value;

        this.items.forEach ((value: HTMLElement, key: DropdownItem) =>
        {
            if (key.prettyValue.includes (searchValue))
            {
                if (value.classList.contains ("hidden"))
                {
                    value.classList.remove ("hidden");
                }
            }
            else
            {
                value.classList.add ("hidden");
            }
        });

        let found: boolean;

        this.items.forEach ((value: HTMLElement, key: DropdownItem) =>
        {
            if (!value.classList.contains ("hidden"))
            {
                found = true;
                return;
            }
        });

        if (found)
        {
            if (!this.notFound.classList.contains ("hidden"))
            {
                this.notFound.classList.add ("hidden");
            }
        }
        else
        {
            if (this.notFound.classList.contains ("hidden"))
            {
                this.notFound.classList.remove ("hidden");
            }
        }
    }
}

export class DropdownItem
{
    public value: string;
    public prettyValue: string;

    constructor (value: string, prettyValue: string)
    {
        this.value = value;
        this.prettyValue = prettyValue;
    }
}
