class Dropdown
{
    private dropdown: HTMLElement;
    private clickable: HTMLElement;
    private selectable: HTMLElement;
    private search: HTMLInputElement;
    private notFound: HTMLElement;
    private visible: boolean;
    private items: HTMLCollectionOf<HTMLElement>;
    private selected: HTMLElement;
    private selectedItem: HTMLElement;

    constructor (dropdown: HTMLElement)
    {
        this.dropdown = dropdown;
        this.clickable = this.dropdown.getElementsByClassName ("clickable") [0] as HTMLElement;
        this.selectable = this.dropdown.getElementsByClassName ("selectable") [0] as HTMLElement;
        this.items = this.selectable.getElementsByClassName ("item") as HTMLCollectionOf<HTMLElement>;
        this.selected = this.clickable.getElementsByClassName ("selected") [0] as HTMLElement;
        this.search = this.dropdown.getElementsByClassName ("search") [0] as HTMLInputElement;
        this.notFound = this.selectable.getElementsByClassName ("not-found") [0] as HTMLElement;

        this.setSelected ();

        this.clickable.addEventListener ("click", () => this.toggleVisible ());

        this.search.addEventListener ("input", () => this.onSearch ());

        for (let i = 0; i < this.items.length; i++)
        {
            this.items [i].addEventListener ("click", (evt) => this.selectItem (evt.target as HTMLElement));
        }

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

    private toggleVisible (): void
    {
        if (this.visible)
        {
            this.dropdown.classList.add ("hidden");
        }
        else
        {
            this.dropdown.classList.remove ("hidden");
        }

        this.visible = !this.visible;
    }

    private selectItem (item: HTMLElement): void
    {
        this.selectedItem.classList.remove ("selected");
        this.selectedItem = item;
        this.selectedItem.classList.add ("selected");
        this.selected.innerText = item.innerText;
        this.toggleVisible ();
    }

    private setSelected (): void
    {
        const selectedText: string = this.selected.innerText;

        for (let i = 0; i < this.items.length; i++)
        {
            if (this.items [i].innerText === selectedText)
            {
                this.items [i].classList.add ("selected");
                this.selectedItem = this.items [i];
                return;
            }
        }
    }

    private onSearch (): void
    {
        const value: string = this.search.value;

        for (let i = 0; i < this.items.length; i++)
        {
            const item: HTMLElement = this.items [i];

            if (item.innerText.includes (value))
            {
                if (item.classList.contains ("hidden"))
                {
                    item.classList.remove ("hidden");
                }
            }
            else
            {
                item.classList.add ("hidden");
            }
        }

        let found: boolean;

        for (let i = 0; i < this.items.length; i++)
        {
            const item: HTMLElement = this.items [i];

            if (!item.classList.contains ("hidden"))
            {
                found = true;
                break;
            }
        }

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

// let expiresInDropdown: HTMLElement = document.getElementById ("expires-in");

// let d: Dropdown = new Dropdown (expiresInDropdown);
