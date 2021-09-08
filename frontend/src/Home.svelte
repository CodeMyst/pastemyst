<script lang="ts">
    import Header from "./components/Header.svelte";
    import TextInput from "./components/TextInput.svelte";
    import TabbedEditor from "./components/TabbedEditor.svelte";
</script>

<main>
    <Header class="header" />

    <TextInput placeholder="title..." />

    <TabbedEditor />
</main>

<style>
    :global(.header) {
        margin-bottom: 2em;
    }

    :global(.tabs) {
        margin-top: 2em;
    }
</style>
