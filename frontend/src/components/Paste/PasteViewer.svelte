<script lang="ts">
    import type { Pasty } from "../../models/Pasty";
    import Tab from "../Tab.svelte";

    export let pasties: Pasty[];
    export let highlightedContent: Array<string>;

    let activePasty = pasties[0];
    let activePatyIndex = 0;
    let codeElement: HTMLElement;

    const onTabClick = (index: number) => {
        activePasty = pasties[index];
        activePatyIndex = index;
    };
</script>

<div class="pasties">
    <div class="tabs">
        <div class="tablist">
            {#each pasties as pasty, i}
                <Tab
                    id={pasty.id}
                    readonly={true}
                    title={pasty.title}
                    active={pasty.id == activePasty.id}
                    on:click={() => onTabClick(i)}
                />
            {/each}
        </div>
    </div>

    <div class="content" bind:this={codeElement}>
        {@html highlightedContent[activePatyIndex]}
    </div>
</div>

<style lang="scss">
    .tabs {
        width: 100%;
        background-color: var(--color-mineshaft);
        display: flex;
        flex-direction: row;
        border-radius: var(--border-radius) var(--border-radius) 0 0;
        align-items: center;
        justify-content: space-between;

        .tablist {
            display: flex;
            flex-direction: row;
            flex-wrap: wrap;
        }
    }
</style>
