<!-- TODO: this is just a copy paste from Select.svele with different styling and a different scrollSelectedIntoView function -->
<script lang="ts">
    import { tick, createEventDispatcher } from "svelte";
    import Popup from "../Popup.svelte";

    export let id: string;
    export let label: string;
    export let options: [string, string][];
    export let placeholder = "filter...";
    export let displayAppend = "";
    export let hiddenLabel = false;

    const dispatch = createEventDispatcher();

    // provided options filtered by a search string
    let filteredOptions: [string, string][] = options;

    let open = false;

    // did the search find any options?
    let found = true;
    let search = "";

    let searchElement: HTMLInputElement;
    let dropdownElement: HTMLElement;

    export let selectedValue: [string, string] = options[0];
    let selectedElement: HTMLElement;

    // set to true when an option is pressed
    let mouseDown = false;

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

    export const setOpen = async (o: boolean): Promise<void> => {
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
                    dispatch("selected");
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
                    selectedValue = index > 0 ? filteredOptions[index - 1] : filteredOptions[0];
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
        dropdownElement.scrollTop = selectedElement.offsetTop - dropdownElement.offsetTop - 34;
    };

    const optionMouseDownHandler = (v: [string, string]) => {
        mouseDown = true;
        selectedValue = v;
    };

    const optionMouseUpHandler = () => {
        mouseDown = false;
        open = false;
        dispatch("selected");
    };

    // finds the index of a tuple in a tuple array
    // this is needed because tuples are objects, and .indexOf would compare references
    const tupleIndexOf = (a: [string, string][], b: [string, string]): number => {
        for (let i = 0; i < a.length; i++) {
            if (tupleEquals(a[i], b)) return i;
        }
    };

    // compares 2 tuples by the contents instead of reference
    const tupleEquals = (a: [string, string], b: [string, string]): boolean => {
        return a[0] === b[0] && a[1] === b[1];
    };
</script>

<div {id} class="container" class:hidden={hiddenLabel}>
    <label id="{id}-label" for="{id}-select" class="select-label">
        {label}
    </label>

    <div
        id="{id}-select"
        class="select"
        aria-labelledby="{id}-label"
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
            {selectedValue[1]}{displayAppend}
        </span>

        <Popup bind:visible={open}>
            <div class="dropdown" role="listbox" bind:this={dropdownElement}>
                <input
                    type="text"
                    autocomplete="off"
                    {placeholder}
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
                            on:mousedown={() => optionMouseDownHandler([key, value])}
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
                            on:mousedown={() => optionMouseDownHandler([key, value])}
                            on:mouseup={optionMouseUpHandler}
                        >
                            {value}
                        </div>
                    {/if}
                {/each}
            </div>
        </Popup>
    </div>
</div>

<style>
    .container {
        display: flex;
        justify-content: space-between;
    }

    .container.hidden .select {
        min-width: 0;
        padding: 0;
    }

    .container.hidden .select .value {
        display: none;
    }

    label {
        display: inline-block;
        margin-right: 0.5em;
        align-self: center;
    }

    .select {
        display: inline-block;
        position: relative;
        color: var(--color-white);
        text-transform: lowercase;
        min-width: 50px;
        height: 100%;
        padding: 0.25em 0.5em;
        margin: -0.25em -0.5em;
    }

    .select .value {
        cursor: pointer;
        padding-right: 2em;
        outline: none;
        border-radius: 0.2em;
        display: block;
        user-select: none;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
        background-color: transparent;
        padding: 0em;
    }

    .select:hover,
    .select.open {
        background-color: var(--color-cod-gray);
    }

    .select .value::after {
        content: "";
        position: absolute;
        right: 12px;
        top: calc(50%);
        transform: translateY(-50%) rotate(90deg);
        pointer-events: none;
    }

    .select.open .value::after {
        content: "";
    }

    .select.open .value {
        border-radius: 0.2em 0.2em 0 0;
    }

    .select.open .dropdown {
        display: flex;
    }

    .dropdown {
        display: none;
        flex-direction: column;
        max-height: 275px;
        overflow-y: auto;
        background-color: var(--color-mineshaft);
        border-radius: var(--border-radius);
    }

    .not-found {
        padding: 0.5em 1em;
    }

    .select input {
        color: var(--color-white);
        border: none;
        padding: 0.5em 1em;
        position: sticky;
        top: 0;
        outline: none;
        text-transform: lowercase;
        background-color: var(--color-mineshaft);
        border-radius: var(--border-radius) var(--border-radius) 0 0;
    }

    .option {
        cursor: pointer;
        padding: 0.5em 1em;
        cursor: pointer;
    }

    .option:hover {
        color: var(--color-main);
        background-color: var(--color-cod-gray-light);
    }

    .option.selected {
        background-color: var(--color-main);
        color: var(--color-cod-gray-light);
    }
</style>
