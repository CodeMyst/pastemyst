<script lang="ts" context="module">
    import { getLangs } from "../services/langs";

    export const load = async () => {
        let langs: Map<string, Language> = await getLangs();

        return {
            props: {
                langs: langs
            }
        };
    };
</script>

<script lang="ts">
    import TextInput from "../components/Input/PasteTitleInput.svelte";
    import TabbedEditor from "../components/Editor/TabbedEditor.svelte";
    import PasteOptions from "../components/Home/PasteOptions.svelte";
    import type { Language } from "../models/Language";
    import { PasteSkeleton, Visibility } from "../models/PasteSkeleton";
    import type { ExpiresIn } from "../models/Expires";
    import { goto } from "$app/navigation";
    import { createPaste } from "../services/pastes";

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

        const paste = await createPaste(skeleton);

        // TODO: error handling
        goto(`/${paste.id}`);
    };
</script>

<TextInput placeholder="title..." bind:title bind:expiresIn />

<TabbedEditor {langs} bind:this={tabbedEditor} />

<PasteOptions on:createPaste={onCreatePaste} />
