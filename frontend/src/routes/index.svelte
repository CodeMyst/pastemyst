<script lang="ts" context="module">
    export const load = async ({ fetch }) => {
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
            lang.tmScope = langJson["tmScope"];

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
    import { PasteSkeleton, Visibility } from "../models/PasteSkeleton";
    import type { ExpiresIn } from "../models/Expires";
    import { API_BASE } from "../constants";
    import { goto } from "$app/navigation";

    export let langs: Map<string, Language>;

    let title: string;
    let expiresIn: [string, string];
    let tabbedEditor: TabbedEditor;

    const onCreatePaste = async () => {
        // TODO: account pastes

        let skeleton: PasteSkeleton = new PasteSkeleton();
        skeleton.title = title;
        skeleton.expiresIn = expiresIn[0] as ExpiresIn;
        skeleton.visibility = Visibility.Pub;
        skeleton.tags = [];
        skeleton.pasties = tabbedEditor.getPasties();

        const res = await fetch(`${API_BASE}/paste/`, {
            method: "post",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(skeleton)
        });

        const json = await res.json();

        // TODO: error handling
        goto(`/${json["_id"]}`);
    };
</script>

<TextInput placeholder="title..." bind:title bind:expiresIn />

<TabbedEditor {langs} bind:this={tabbedEditor} />

<PasteOptions on:createPaste={onCreatePaste} />
