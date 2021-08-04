<script lang="ts">

    import { onMount } from "svelte";

    import { EditorState, EditorView, basicSetup } from "@codemirror/basic-setup";
    import { javascript } from "@codemirror/lang-javascript";
    import { myst } from "../cm-themes/myst";
    import { Select } from "select.myst";

    let langsPromise = loadLangs();

    let editorElement: HTMLElement;

    let editorView: EditorView;

    let line: number = 0;
    let pos: number = 0;

    let indentAmount: number = 4;
    let indentType: string = "spaces";

    onMount(() => {
        let updateListener = EditorView.updateListener.of((update) => {
            let cmLine = update.state.doc.lineAt(update.state.selection.main.head);
            line = cmLine.number;
            pos = update.state.selection.main.head - cmLine.from;
        });

        editorView = new EditorView({
            state: EditorState.create({
                extensions: [basicSetup, myst, javascript(), updateListener]
            }),
            parent: editorElement
        });

        line = editorView.state.selection.main.head;
        pos = editorView.state.selection.main.from;
    });

    /**
     * Loading all the languages from the API.
     */
    async function loadLangs(): Promise<[String,String][]> {
        // TODO: turn the host into a var
        let res = await fetch("http://localhost:5001/api/v3/data/langs",
            {
                headers: {
                    "Content-Type": "application/json"
                }
            });

        let json: JSON = await res.json();

        let langs: [String, String][] = new Array<[String, String]>();

        for (let lang in json) {
            langs.push([lang, lang]);
        }

        return langs;
    }

</script>

<style>

    .editor {
        margin-top: 2em;
    }

    :global(.cm-editor) {
        border-radius: var(--border-radius) var(--border-radius) 0 0;
    }

    :global(.cm-gutters) {
        border-radius: var(--border-radius) 0 0 0;
    }

    :global(.cm-editor:focus),
    :global(.cm-focused) {
        outline: none !important;
    }

    :global(.cm-content),
    :global(.cm-gutter) {
        height: 500px;
    }

    :global(.cm-scroller) {
        overflow: auto;
    }

    :global(.cm-wrap) {
        height: 500px;
    }

    .toolbar {
        background-color: var(--color-mineshaft);
        border-radius: 0 0 var(--border-radius) var(--border-radius);
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        padding: 0.25em 1em;
    }

    .toolbar .right {
        display: flex;
        flex-direction: row;
    }

    .toolbar .right .pos {
        margin-right: 2em;
    }

</style>

<div class="editor" bind:this={editorElement}></div>

<div class="toolbar">
    <div class="left">
        {#await langsPromise}
            <p>loading...</p>
        {:then langs}
            <Select id="language"
                    label="lang:"
                    options={langs} />
        {/await}
    </div>
    <div class="right">
        <div class="pos">
            ln {line} pos {pos}
        </div>
        <div class="indent">
            {indentAmount} {indentType}
        </div>
    </div>
</div>
