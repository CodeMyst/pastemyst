<script lang="ts">
    import { createEventDispatcher, tick } from "svelte";

    export let id: string;
    export let active = false;
    export let title = "untitled";
    export let renameState = false;
    export let readonly = false;

    let dispatch = createEventDispatcher();

    let inputField: HTMLInputElement;

    const onClick = (event: MouseEvent) => {
        dispatch("click", { event: event });
    };

    const onDoubleClick = async () => {
        if (readonly) return;

        renameState = true;

        await tick();

        inputField.focus();
        onInput();
    };

    const onInputBlur = () => {
        renameState = false;
    };

    // when renaming a tab, set its width based on the content
    const onInput = () => {
        inputField.style.width = inputField.value.length + "ch";
    };

    // if enter or escape is pressed, exit from rename state
    const onInputKeyPress = (event: KeyboardEvent) => {
        if (event.key === "Enter" || event.key === "Escape") onInputBlur();
    };

    const onClose = () => {
        dispatch("close");
    };
</script>

<div
    class="tab"
    class:active
    class:rename-state={renameState}
    on:click={onClick}
    on:dblclick={onDoubleClick}
    data-id={id}
>
    {#if renameState}
        <input
            type="text"
            bind:value={title}
            bind:this={inputField}
            on:blur={onInputBlur}
            on:input={onInput}
            on:keyup={onInputKeyPress}
        />
    {:else}
        <span class="title">{title}</span>
    {/if}

    {#if !readonly}
        <span class="close-icon" on:click={onClose}>
            <ion-icon name="close" />
        </span>
    {/if}
</div>

<style>
    .tab {
        background-color: var(--color-cod-gray-light);
        padding: 0.5em 1em;
        display: flex;
        flex-direction: row;
        align-items: center;
        cursor: pointer;
        border-bottom: 1px solid var(--color-cod-gray-light);
        user-select: none;
        white-space: nowrap;
        justify-content: space-between;
        flex-grow: 0.25;
    }

    .tab.active {
        border-color: var(--color-main);
    }

    .tab.rename-state {
        border-color: var(--color-accent);
    }

    .tab:hover {
        background-color: var(--color-mineshaft);
    }

    .tab:first-child {
        border-radius: var(--border-radius) 0 0;
    }

    .tab .title {
        margin-right: 0.75em;
    }

    .tab .close-icon {
        cursor: pointer;
        padding: 0.25em;
        margin: -0.25em;
        border-radius: var(--border-radius);
    }

    .tab .close-icon:hover {
        background-color: var(--color-cod-gray);
    }

    .tab input {
        background-color: transparent;
        border-radius: var(--border-radius);
        color: var(--color-accent);
        border: none;
        outline: none;
        width: auto;
        padding: 0;
        margin-right: 0.75em;
    }
</style>
