export type OnChangeDelegate = (newItem: DropdownItem) => void;

export class Dropdown
{
    public selectedItem: DropdownItem;

    public onChange: OnChangeDelegate;
    
    private dropdown: HTMLElement;
    private clickable: HTMLElement;
    private selectable: HTMLElement;
    private search: HTMLInputElement;
    private notFound: HTMLElement;
    private selectedText: HTMLElement;
    private visible: boolean;
    private items: Map<DropdownItem, HTMLElement>;
    private selectedItemElement: [DropdownItem, HTMLElement];

    constructor (dropdown: HTMLElement, label: string, hasSearch: boolean)
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

        (this.dropdown.getElementsByClassName ("label") [0].children [0] as HTMLElement).innerText = label;

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
        const itemNode: HTMLDivElement = document.createElement ("div");
        itemNode.classList.add ("item");
        itemNode.innerText = item.prettyValue;
        itemNode.addEventListener ("click", (evt) => this._selectItem ([item, evt.target as HTMLElement]));
        this.selectable.getElementsByClassName ("items") [0].appendChild (itemNode);

        this.items.set (item, itemNode);
    }

    public selectItem (item: DropdownItem): void
    {
        this._selectItem ([item, this.items.get (item)]);
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
        if (this.onChange !== undefined)
        {
            this.onChange (this.selectedItem);
        }
    }

    private onSearch (): void
    {
        const searchValue: string = this.search.value;

        this.items.forEach ((value: HTMLElement, key: DropdownItem) =>
        {
            if (key.prettyValue.toLowerCase ().includes (searchValue.toLowerCase ()))
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
    public values: string [];
    public prettyValue: string;

    constructor (values: string [], prettyValue: string)
    {
        this.values = values;
        this.prettyValue = prettyValue;
    }
}
