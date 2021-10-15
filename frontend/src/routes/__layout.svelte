<script lang="ts" context="module">
    import "../app.scss";
    import "../styles/normalize.css";

    import Footer from "../components/Footer.svelte";
    import Header from "../components/Header.svelte";
</script>

<main>
    <Header />

    <slot />
</main>

<Footer />
