<script lang="ts">
    import Header from "./components/Header.svelte";
    import TextInput from "./components/TextInput.svelte";
    import TabbedEditor from "./components/TabbedEditor.svelte";
    import PasteOptions from "./components/PasteOptions.svelte";
    import Footer from "./components/Footer.svelte";
</script>

<main>
    <Header class="header" />

    <TextInput placeholder="title..." />

    <TabbedEditor />

    <PasteOptions />
</main>

<Footer />

<style>
    :global(.header) {
        margin-bottom: 2em;
    }

    :global(.tabs) {
        margin-top: 2em;
    }

    :global(.paste-options) {
        margin-top: 2em;
    }

    :global(footer) {
        margin-top: 2em;
    }
</style>
