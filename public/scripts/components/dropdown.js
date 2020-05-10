export default class Dropdown
{
    constructor(container)
    {
        this.onValueChange = () => { };
        this.container = container;
        this.search = this.container.querySelector(".select > input");
        this.notFound = this.container.querySelector(".select > .not-found");
        this.options = this.container.querySelectorAll(".select > .option");
        this.value = this.container.querySelector("summary").textContent;
        this.checked = this.container.querySelector("input[checked]");
        this.mouseDown = false;
        this.addEventListeners();
        this.setAria();
        this.updateValue();
    }

    addEventListeners()
    {
        this.container.addEventListener("toggle", () =>
        {
            if (this.container.open)
            {
                return;  
            }
            this.updateValue();
        });

        this.container.addEventListener("focusout", (e) =>
        {
            if (this.mouseDown || e.relatedTarget === this.search)
            {
                return;
            }
            this.container.removeAttribute("open");
        }, true);

        this.options.forEach((opt) =>
        {
            opt.addEventListener("mousedown", () =>
            {
                this.mouseDown = true;
            });

            opt.addEventListener("mouseup", () =>
            {
                this.mouseDown = false;
                this.container.removeAttribute("open");
            });
        });

        this.container.addEventListener("keyup", (e) =>
        {
            const keycode = e.which;
            const current = [...this.options].indexOf(this.container.querySelector(".active"));
            switch (keycode)
            {
                case 27: // ESC
                    this.container.removeAttribute("open");
                    break;
                case 35: // END
                    e.preventDefault();
                    if (!this.container.open)
                    {
                        this.container.setAttribute("open", "");
                    }
                    this.setChecked(this.options[this.options.length - 1].querySelector("input"));
                    break;
                case 36: // HOME
                    e.preventDefault();
                    if (!this.container.open)
                    {
                        this.container.setAttribute("open", "");
                    }
                    this.setChecked(this.options[0].querySelector("input"));
                    break;
                case 38: // UP
                    e.preventDefault();
                    if (!this.container.open)
                    {
                        this.container.setAttribute("open", "");
                    }
                    this.setChecked(this.options[current > 0 ? current - 1 : 0].querySelector("input"));
                    break;
                case 40: // DOWN
                    e.preventDefault();
                    if (!this.container.open)
                    {
                        this.container.setAttribute("open", "");
                    }
                    this.setChecked(this.options[current < this.options.length - 1 ? current + 1 : this.options.length - 1].querySelector("input"));
                    break;
            }
        });
    
        this.search.addEventListener("input", () => this.onSearch());
    }

    onSearch()
    {
        const searchValue = this.search.value.toLowerCase();

        let found;

        this.options.forEach((opt) =>
        {
            let val = opt.getElementsByTagName("span")[0].textContent.toLowerCase();

            if (val.includes(searchValue))
            {
                found = true;

                if (opt.classList.contains("hidden"))
                {
                    opt.classList.remove("hidden");
                }
            }
            else
            {
                opt.classList.add("hidden");
            }
        });

        if (found)
        {
            if (!this.notFound.classList.contains("hidden"))
            {
                this.notFound.classList.add("hidden");
            }
        }
        else
        {
            if (this.notFound.classList.contains("hidden"))
            {
                this.notFound.classList.remove("hidden");
            }
        }
    }

    setAria()
    {
        this.container.setAttribute("aria-haspopup", "listbox");
        this.container.querySelector(".select").setAttribute("role", "listbox");
        const summary = this.container.querySelector("summary");
        summary.setAttribute("aria-label", `unselected listbox`);
        summary.setAttribute("aria-live", `polite`);
        this.options.forEach((opt) =>
        {
            opt.setAttribute("role", "option");
        });
    }

    updateValue()
    {
        const that = this.container.querySelector("input:checked");
        if (!that)
        {
            return;
        }
        this.setValue(that);
    }

    setChecked(that)
    {
        that.checked = true;
        this.setValue(that);
    }

    setValue(that)
    {
        if (this.value === that.value)
        {
            return;
        }

        this.checked.checked = false;

        const summary = this.container.querySelector("summary");
        const pos = [...this.options].indexOf(that.parentNode) + 1;
        summary.textContent = that.parentNode.textContent;
        summary.setAttribute("aria-label", `${that.value}, listbox ${pos} of ${this.options.length}`);
        this.value = that.value;
        this.checked = this.container.querySelector("input[checked]");

        this.options.forEach((opt) =>
        {
            opt.classList.remove("active");
            opt.setAttribute("aria-selected", "false");
        });
        that.parentNode.classList.add("active");
        that.parentNode.setAttribute("aria-selected", "true");

        this.search.value = "";
        this.onSearch();
        this.container.dispatchEvent(new Event ("change"));
        this.onValueChange(this.value);
    }

    resetValue()
    {
        this.setValue(this.container.querySelector(".option input"));
    }
}
