<script lang="ts">
    import Tab from "../Tab.svelte";
    import Sortable from "sortablejs";
    import Editor from "./Editor.svelte";
    import { onMount, tick } from "svelte";
    import type { Language } from "src/models/Language";

    class STab {
        title: string;
        id: string;
        renameState: boolean;
        editor: Editor;

        constructor(id: string, title: string, editor: Editor) {
            this.id = id;
            this.title = title;
            this.editor = editor;
        }
    }

    export let langs: Map<string, Language>;

    let editorTarget: HTMLElement;

    export let tabs: STab[] = new Array<STab>();
    let activeTabId: String;

    let tablist: HTMLElement;

    // used to give every tab its own unique id number
    let tabCounter: number = 0;

    onMount(async () => {
        Sortable.create(tablist, {
            direction: "horizontal",
            animation: 150,

            onEnd: (event) => {
                // once the reordering of a tab is done, replicate the reorder in the tab array
                const tab = tabs[event.oldIndex];
                tabs.splice(event.oldIndex, 1);
                tabs.splice(event.newIndex, 0, tab);
                tabs = tabs;
            }
        });

        await onTabAdd();
    });

    // when the add tab button is pressed
    const onTabAdd = async () => {
        let newTab = new STab(
            tabCounter.toString(),
            "untitled",
            new Editor({ target: editorTarget })
        );

        newTab.editor.$set({ langs: langs });

        await tick();

        // add tab to array
        tabs = [...tabs, newTab];
        await setActiveTab(tabs[tabs.length - 1].id);

        tabCounter++;
    };

    // when a tab is closed
    const onTabClose = async (index: number) => {
        // can't close if its the last tab
        if (tabs.length === 1) return;

        // destroy the editor in the DOM
        tabs[index].editor.$destroy();

        // remove the tab from the tabs array
        tabs = [...tabs.slice(0, index), ...tabs.slice(index + 1, tabs.length)];

        // set the previous tab as active
        if (tabs.findIndex((t) => t.id === activeTabId) >= 1)
            await setActiveTab(tabs[tabs.length - 1].id);
        // if the first tab is closed, set the next first tab as active
        else await setActiveTab(tabs[0].id);

        updateTabEditorVisibility();
    };

    // when a tab is clicked
    const onTabClick = async (index: number, event: CustomEvent<any>) => {
        let target = event.detail.event.target as HTMLElement;

        // ignore if close icon is pressed
        if (target.nodeName === "ION-ICON") return;

        // ignore if double click, so the tab rename field doesn't unfocus
        if (event.detail.event.detail > 1) return;

        await setActiveTab(tabs[index].id);
    };

    // set the new active tab
    const setActiveTab = async (id: String) => {
        activeTabId = id;

        updateTabEditorVisibility();

        // requires 2 DOM ticks for some reason because of the editor visibility
        await tick();
        await tick();

        let tab = tabs.find((t) => t.id === activeTabId);

        if (!tab.renameState) {
            tab.editor.focus();
        }
    };

    // goes through all the editors in the DOM and sets the hidden property based if the tab is active or not
    const updateTabEditorVisibility = () => {
        for (let i = 0; i < tabs.length; i++) {
            tabs[i].editor.$set({ hidden: !(tabs[i].id === activeTabId) });
        }
    };
</script>

<div class="tabs">
    <div class="tablist" bind:this={tablist}>
        {#each tabs as tab, i (tab.id)}
            <Tab
                on:close={() => onTabClose(i)}
                on:click={(event) => onTabClick(i, event)}
                bind:renameState={tab.renameState}
                bind:title={tab.title}
                id={tab.id}
                active={activeTabId === tab.id}
            />
        {/each}
    </div>

    <div class="add-icon" on:click={onTabAdd}>
        <ion-icon name="add" />
    </div>
</div>

<div class="editor" bind:this={editorTarget} />

<style>
    .tabs {
        width: 100%;
        background-color: var(--color-mineshaft);
        display: flex;
        flex-direction: row;
        border-radius: var(--border-radius) var(--border-radius) 0 0;
        align-items: center;
        justify-content: space-between;
    }

    .tabs .tablist {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
    }

    .tabs .add-icon {
        margin-left: 0.5em;
        margin-right: 0.5em;
        margin-top: 0.35em;
        align-self: flex-start;
        cursor: pointer;
        padding: 0.25em;
        border-radius: var(--border-radius);
    }

    .tabs .add-icon:hover {
        background-color: var(--color-cod-gray);
    }
</style>
