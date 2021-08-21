<script lang="ts">
    import TabList from "./TabList.svelte";

    let tablist: TabList;

    let editorTarget: HTMLElement;
</script>

<div class="tabbed-editor">
    <TabList bind:this={tablist} />

    <div class="editor" bind:this={editorTarget}>
    </div>
</div>
