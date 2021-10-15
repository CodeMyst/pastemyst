<script lang="ts">
	import Footer from "../components/Footer.svelte";
	import Header from "../components/Header.svelte";
</script>

<main>
	<Header />

	<slot />
</main>

<Footer />