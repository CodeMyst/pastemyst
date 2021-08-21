<script lang="ts">
    import { onMount } from "svelte";
    import Tab from "./Tab.svelte";
    import Sortable from "sortablejs";

    class STab {
        id: String;
        title: String;

        constructor(id: String, title: String) {
            this.id = id;
            this.title = title;
        }
    }

    export let tabs: STab[] = new Array<STab>();
    let activeTabId: String;

    let tablist: HTMLElement;

    // todo: this can be removed once this is complete
    let tabCounter: number = 0;

    onMount(() => {
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

        onTabAdd();
    });

    // when the add tab button is pressed
    const onTabAdd = () => {
        let newTab = new STab(tabCounter.toString(), `tab ${tabs.length}`);
        tabs = [...tabs, newTab];
        setActiveTab(tabs[tabs.length - 1].id);

        tabCounter++;
    };

    // when a tab is closed
    const onTabClose = (index: number) => {
        // can't close if its the last tab
        if (tabs.length === 1) return;

        tabs = [...tabs.slice(0, index), ...tabs.slice(index + 1, tabs.length)];

        // set the previous tab as active
        if (tabs.findIndex(t => t.id === activeTabId) >= 1) setActiveTab(tabs[tabs.length - 1].id);
        // if the first tab is closed, set the next first tab as active
        else setActiveTab(tabs[0].id);
    };

    // when a tab is clicked
    const onTabClick = (index: number, event: CustomEvent<any>) => {
        let target = event.detail.event.target as HTMLElement;
        // ignore if close icon is pressed
        if (target.nodeName === "ION-ICON") return;

        setActiveTab(tabs[index].id);
    };

    // set the new active tab
    const setActiveTab = (id: String) => {
        activeTabId = id;
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

<style>
    .tabs {
        width: 100%;
        background-color: var(--color-mineshaft);
        display: flex;
        flex-direction: row;
        border-radius: var(--border-radius) var(--border-radius) 0 0;
        align-items: center;
    }

    .tabs .tablist {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
    }

    .tabs .add-icon {
        margin-left: 0.5em;
        margin-right: 0.5em;
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
