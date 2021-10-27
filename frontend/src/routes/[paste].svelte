<script lang="ts" context="module">
    export async function load({ page, fetch, session, stuff }) {
        const url = `/${page.params.paste}.json`;
        const res = await fetch(url);
        const json = await res.json();

        if (res.ok) {
            return {
                props: {
                    paste: json
                }
            };
        }

        return {
            status: res.status,
            error: new Error(`could not load ${url}`)
        };
    }
</script>

<script lang="ts">
    import PasteTitle from "../components/Paste/PasteTitle.svelte";
    import type { Paste } from "src/models/Paste";

    export let paste: Paste;
</script>

<PasteTitle title={paste.title} />
