<script lang="ts">

    import { onMount } from "svelte";

    import { EditorState, EditorView, basicSetup } from "@codemirror/basic-setup";
    import { javascript } from "@codemirror/lang-javascript";
    import { myst } from "../cm-themes/myst";

    let editorElement: HTMLElement;

    onMount(() => {
        new EditorView({
            state: EditorState.create({
                extensions: [basicSetup, myst, javascript()]
            }),
            parent: editorElement
        });
    });

</script>

<style>

    .editor {
        margin-top: 2em;
    }

    :global(.cm-editor) {
        border-radius: var(--border-radius);
    }

    :global(.cm-gutters) {
        border-radius: var(--border-radius) 0 0 var(--border-radius);
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

</style>

<div class="editor" bind:this={editorElement}></div>
