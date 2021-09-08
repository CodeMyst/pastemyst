<script lang="ts">
    import Tab from "./Tab.svelte";
    import Sortable from "sortablejs";
    import Editor from "./Editor.svelte";
    import { onMount, tick } from "svelte";

    class STab {
        id: String;
        title: String;
        editor: Editor;

        constructor(id: String, title: String, editor: Editor) {
            this.id = id;
            this.title = title;
            this.editor = editor;
        }
    }

    let editorTarget: HTMLElement;

    export let tabs: STab[] = new Array<STab>();
    let activeTabId: String;

    let tablist: HTMLElement;

    // todo: this can be removed once this is complete
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
            },
        });

        await onTabAdd();
    });

    // when the add tab button is pressed
    const onTabAdd = async () => {
        let newTab = new STab(
            tabCounter.toString(),
            `tab ${tabs.length}`,
            new Editor({ target: editorTarget })
        );
        tabs = [...tabs, newTab];
        await setActiveTab(tabs[tabs.length - 1].id);

        tabCounter++;
    };

    // when a tab is closed
    const onTabClose = async (index: number) => {
        // can't close if its the last tab
        if (tabs.length === 1) return;

        tabs[index].editor.$destroy();

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

        await setActiveTab(tabs[index].id);
    };

    // set the new active tab
    const setActiveTab = async (id: String) => {
        activeTabId = id;

        updateTabEditorVisibility();

        await tick();
        await tick();

        tabs.find((t) => t.id === activeTabId).editor.focus();
    };

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
                id={tab.id}
                title={tab.title}
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

    .tabs .tablist :global(.sortable-drag) {
        display: none;
    }

    .tabs .tablist :global(.sortable-chosen) {
        box-shadow: rgba(0, 0, 0, 0.35) 0px 5px 15px;
        z-index: 10;
        background-color: var(--color-mineshaft);
    }
</style>
