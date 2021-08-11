<script lang="ts">
    import Header from "./components/Header.svelte";
    import TextInput from "./components/TextInput.svelte";
    import Editor from "./components/Editor.svelte";
</script>

<main>
    <Header class="header" />

    <TextInput placeholder="title..." />

    <Editor />
</main>

<style>
    :global(.header) {
        margin-bottom: 2em;
    }
</style>
