<script lang="ts" context="module">
    export const load = async ({ page, fetch }) => {
        const url = `/internal/${page.params.paste}.json`;
        const res = await fetch(url);
        const json = await res.json();

        if (res.ok) {
            return {
                props: {
                    paste: json.paste,
                    highlightedContent: json.highlightedContent
                }
            };
        }

        return {
            status: res.status,
            error: new Error(`could not load ${url}`)
        };
    };
</script>

<script lang="ts">
    import PasteTitle from "../components/Paste/PasteTitle.svelte";
    import PasteViewer from "../components/Paste/PasteViewer.svelte";
    import type { Paste } from "src/models/Paste";

    export let paste: Paste;
    export let highlightedContent: Array<string>;
</script>

<PasteTitle title={paste.title} />

<PasteViewer pasties={paste.pasties} {highlightedContent} />
