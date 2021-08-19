<script lang="ts">
import { indentUnit } from "@codemirror/language";

import { onMount, tick } from "svelte";

    import Editor from "./Editor.svelte";

    class Tab {
        title: String;
        editor: Editor;

        constructor(title: String, editor: Editor) {
            this.title = title;
            this.editor = editor;
        }
    }

    let editorTarget: HTMLElement;

    let tabs: Tab[] = new Array<Tab>();
    let activeTabIndex: number = 0;

    onMount(async () => {
        await onTabAdd();
    });

    async function onTabAdd() {
        let newTab = new Tab(tabs.length.toString(), new Editor({target: editorTarget}));
        tabs = [...tabs, newTab];
        await setActiveTab(tabs.length - 1);
    }

    async function onTabClose(index: number) {
        if (tabs.length === 1) return;

        if (activeTabIndex >= tabs.length - 1) await setActiveTab(activeTabIndex - 1);

        tabs[index].editor.$destroy();

        tabs = [...tabs.slice(0, index), ...tabs.slice(index + 1, tabs.length)];

        updateTabEditorVisibility();
    }

    async function onTabClick(index: number, event: MouseEvent) {
        let t = event.target as HTMLElement;
        if (t.nodeName === "ION-ICON") return;

        await setActiveTab(index);
    }

    async function setActiveTab(index: number) {
        activeTabIndex = index;

        updateTabEditorVisibility();

        await tick();
        await tick();

        tabs[activeTabIndex].editor.focus();
    }

    function updateTabEditorVisibility() {
        for (let i = 0; i < tabs.length; i++) {
            tabs[i].editor.$set({ hidden: !(i === activeTabIndex) });
        }
    }
</script>

<div class="tabbed-editor">
    <div class="tabs">
        {#each tabs as tab, i}
            <div
                class="tab"
                class:active={i === activeTabIndex}
                on:click={(event) => onTabClick(i, event)}
            >
                <span class="title">{tab.title}</span>
                <span class="close-icon" on:click={() => onTabClose(i)}>
                    <ion-icon name="close" />
                </span>
            </div>
        {/each}

        <div class="add-icon" on:click={onTabAdd}>
            <ion-icon name="add" />
        </div>
    </div>

    <div class="editor" bind:this={editorTarget}>
    </div>
</div>

<style>
    .tabs {
        width: 100%;
        background-color: var(--color-mineshaft);
        display: flex;
        flex-direction: row;
        border-radius: var(--border-radius) var(--border-radius) 0 0;
        align-items: center;
    }

    .tabs .tab {
        background-color: var(--color-cod-gray-light);
        padding: 0.5em 1em;
        display: flex;
        flex-direction: row;
        align-items: center;
        cursor: pointer;
        border-bottom: 1px solid var(--color-cod-gray-light);
    }

    .tabs .tab.active {
        border-color: var(--color-main);
    }

    .tabs .tab:hover {
        background-color: var(--color-mineshaft);
    }

    .tabs .tab:first-child {
        border-radius: var(--border-radius) 0 0;
    }

    .tabs .tab .title {
        margin-right: 0.75em;
    }

    .tabs .tab .close-icon {
        cursor: pointer;
        padding: 0.25em;
        margin: -0.25em;
        border-radius: var(--border-radius);
    }

    .tabs .tab .close-icon:hover {
        background-color: var(--color-cod-gray);
    }

    .tabs .add-icon {
        margin-left: 0.5em;
        cursor: pointer;
        padding: 0.25em;
        border-radius: var(--border-radius);
    }

    .tabs .add-icon:hover {
        background-color: var(--color-cod-gray);
    }
</style>
