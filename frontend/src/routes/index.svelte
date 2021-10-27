<script lang="ts" context="module">
    export const load = async ({ page, fetch }) => {
        // load langs
        const url = "/internal/langs.json";
        const res = await fetch(url);
        const json = await res.json();

        let langs: Map<string, Language> = new Map<string, Language>();

        // converting manually because when marking the proper types through the load function
        // the json doesn't correctly get deserialized into the map
        for (const langName in json) {
            const langJson = json[langName];

            const lang = new Language();
            lang.type = langJson["type"];
            lang.aliases = langJson["aliases"];
            lang.codemirrorMode = langJson["codemirrorMode"];
            lang.codemirrorMimeType = langJson["codemirrorMimeType"];
            lang.extensions = langJson["extensions"];
            lang.filenames = langJson["filenames"];
            lang.color = langJson["color"];
            lang.group = langJson["gruop"];

            langs.set(langName, lang);
        }

        if (res.ok) {
            return {
                props: {
                    langs: langs
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
    import TextInput from "../components/Input/PasteTitleInput.svelte";
    import TabbedEditor from "../components/Editor/TabbedEditor.svelte";
    import PasteOptions from "../components/Home/PasteOptions.svelte";
    import { Language } from "../models/Language";

    export let langs: Map<string, Language>;
</script>

<TextInput placeholder="title..." />

<TabbedEditor {langs} />

<PasteOptions />
