<script lang="ts">
    import { tick } from "svelte";

    export let id: string;
    export let label: String;
    export let options: [String, String][];

    // provided options filtered by a search string
    let filteredOptions: [String, String][] = options;

    let open: boolean = false;

    // did the search find any options?
    let found: boolean = true;
    let search: string = "";

    let selectElement: HTMLElement;
    let searchElement: HTMLInputElement;
    let dropdownElement: HTMLElement;

    export let selectedValue: [String, String] = options[0];
    let selectedElement: HTMLElement;

    // set to true when an option is pressed
    let mouseDown: boolean = false;

    // filters options by a search string
    // both the key and value are compared
    const filterOptions = () => {
        filteredOptions = options.filter(
            (e) =>
                e[0].toLowerCase().indexOf(search.toLowerCase()) > -1 ||
                e[1].toLowerCase().indexOf(search.toLowerCase()) > -1
        );

        found = filteredOptions.length > 0;

        if (found) {
            selectedValue = filteredOptions[0];
        }
    };

    // when the value element is pressed toggle the open state
    const valueClickHandler = async (e: MouseEvent) => {
        await setOpen(!open);
        // prevents the focus element from firing which would just immediately close the select
        e.preventDefault();
    };

    // when the value element is focused open the select,
    // focusing on an element by tabbing should never close it
    const valueFocusHandler = async () => {
        await setOpen(true);
    };

    const setOpen = async (o: boolean) => {
        open = o;

        // after opening, wait for the DOM to update
        // and reset the search
        if (open) {
            await tick();

            searchElement.focus();
            search = "";
            filteredOptions = options;
            scrollSelectedIntoView();
        }
    };

    // when focus is lost on the search bar close the select
    const searchBlurHandler = () => {
        // dont trigger if an option is selected
        if (mouseDown) return;

        open = false;
    };

    // key handler for the search bar
    const keyDownHandler = async (e: KeyboardEvent) => {
        switch (e.key) {
            // close the dropdown
            case "Escape":
            case "Enter":
                {
                    open = false;
                }
                break;

            // select the last option
            case "End":
                {
                    e.preventDefault();
                    selectedValue = filteredOptions[filteredOptions.length - 1];
                    await tick();
                    scrollSelectedIntoView();
                }
                break;

            // select the first option
            case "Home":
                {
                    e.preventDefault();
                    selectedValue = filteredOptions[0];
                    await tick();
                    scrollSelectedIntoView();
                }
                break;

            case "ArrowUp":
                {
                    e.preventDefault();
                    const index = tupleIndexOf(filteredOptions, selectedValue);
                    selectedValue =
                        index > 0
                            ? filteredOptions[index - 1]
                            : filteredOptions[0];
                    await tick();
                    scrollSelectedIntoView();
                }
                break;

            case "ArrowDown":
                {
                    e.preventDefault();
                    const index = tupleIndexOf(filteredOptions, selectedValue);
                    selectedValue =
                        index < filteredOptions.length - 1
                            ? filteredOptions[index + 1]
                            : filteredOptions[filteredOptions.length - 1];
                    await tick();
                    scrollSelectedIntoView();
                }
                break;
        }
    };

    const scrollSelectedIntoView = () => {
        dropdownElement.scrollTop =
            selectedElement.offsetTop - dropdownElement.offsetTop;
    };

    const optionMouseDownHandler = (v: [String, String]) => {
        mouseDown = true;
        selectedValue = v;
    };

    const optionMouseUpHandler = () => {
        mouseDown = false;
        open = false;
    };

    // finds the index of a tuple in a tuple array
    // this is needed because tuples are objects, and .indexOf would compare references
    const tupleIndexOf = (
        a: [String, String][],
        b: [String, String]
    ): number => {
        for (let i = 0; i < a.length; i++) {
            if (tupleEquals(a[i], b)) return i;
        }
    };

    // compares 2 tuples by the contents instead of reference
    const tupleEquals = (a: [String, String], b: [String, String]): boolean => {
        return a[0] === b[0] && a[1] === b[1];
    };
</script>

<div {id} class="container">
    <label id="{id}-label" for="{id}-select" class="select-label">
        {label}
    </label>

    <div
        id="{id}-select"
        class="select"
        aria-labelledby="{id}-label"
        bind:this={selectElement}
        class:open
    >
        <span
            class="value"
            tabindex="0"
            aria-label="{selectedValue[1]}, listbox {tupleIndexOf(
                options,
                selectedValue
            )} of {options.length}"
            aria-live="polite"
            role="combobox"
            aria-labelledby="{id}-label"
            aria-haspopup="listbox"
            aria-expanded={open}
            on:mousedown={valueClickHandler}
            on:focus={valueFocusHandler}
        >
            {selectedValue[1]}
        </span>

        <div class="dropdown" role="listbox" bind:this={dropdownElement}>
            <input
                type="text"
                autocomplete="off"
                placeholder="Filter..."
                bind:this={searchElement}
                bind:value={search}
                on:input={filterOptions}
                on:keydown={keyDownHandler}
                on:blur={searchBlurHandler}
            />

            {#if !found}
                <p class="not-found">No items found</p>
            {/if}

            {#each filteredOptions as [key, value]}
                {#if tupleEquals(selectedValue, [key, value])}
                    <div
                        class="option selected"
                        aria-selected="true"
                        role="option"
                        on:mousedown={() =>
                            optionMouseDownHandler([key, value])}
                        on:mouseup={optionMouseUpHandler}
                        bind:this={selectedElement}
                    >
                        {value}
                    </div>
                {:else}
                    <div
                        class="option"
                        aria-selected="false"
                        role="option"
                        on:mousedown={() =>
                            optionMouseDownHandler([key, value])}
                        on:mouseup={optionMouseUpHandler}
                    >
                        {value}
                    </div>
                {/if}
            {/each}
        </div>
    </div>
</div>

<style>
    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    .container {
        display: flex;
    }

    label {
        display: inline-block;
        margin-right: 0.5em;
        align-self: center;
    }

    .select {
        display: inline-block;
        position: relative;
        color: #ffffff;
        width: 200px;
    }

    .select .value {
        cursor: pointer;
        padding: 0.5em 1em;
        padding-right: 2em;
        background-color: #141414;
        outline: none;
        border-radius: 0.2em;
        display: block;
        user-select: none;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
    }

    .select .value::after {
        content: "\00203A";
        position: absolute;
        right: 12px;
        top: calc(50%);
        transform: translateY(-50%) rotate(90deg);
        pointer-events: none;
    }

    .select.open .value::after {
        content: "\002039";
    }

    .select.open .value {
        border-radius: 0.2em 0.2em 0 0;
    }

    .select.open .dropdown {
        display: flex;
    }

    .dropdown {
        position: absolute;
        display: none;
        flex-direction: column;
        width: 100%;
        background: #141414;
        z-index: 999;
        max-height: 275px;
        overflow-y: auto;
        border-radius: 0 0 0.2em 0.2em;
    }

    .not-found {
        padding: 0.5em 1em;
    }

    .select input {
        background-color: #1c1c1c;
        color: #ffffff;
        border: none;
        padding: 0.5em 1em;
        position: sticky;
        top: 0;
        outline: none;
    }

    .option {
        cursor: pointer;
        padding: 0.5em 1em;
        cursor: pointer;
    }

    .option:hover {
        color: orange;
        background-color: #1c1c1c;
    }

    .option.selected {
        background-color: orange;
        color: #1c1c1c;
    }
</style>
