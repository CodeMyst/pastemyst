<script lang="ts">
    import { createEventDispatcher, onMount } from "svelte";

    export let id: String;
    export let active: boolean = false;
    export let title: String = "untitled";

    let dispatch = createEventDispatcher();

    const onClick = (event: MouseEvent) => {
        dispatch("click", { event: event });
    };

    const onClose = () => {
        dispatch("close");
    };
</script>

<div
    class="tab"
    class:active
    on:click={onClick}
    data-id={id}
>
    <span class="title">{title}</span>
    <span class="close-icon" on:click={onClose}>
        <ion-icon name="close" />
    </span>
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
</style>
