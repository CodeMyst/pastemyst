<script lang="ts">
    import { onMount } from "svelte";
    import { EditorState, basicSetup } from "@codemirror/basic-setup";
    import { EditorView, keymap } from "@codemirror/view";
    import { Compartment } from "@codemirror/state";
    import { indentWithTab } from "@codemirror/commands";
    import { indentUnit } from "@codemirror/language";
    import { myst } from "../cm-themes/myst";
    import BigSelect from "./BigSelect.svelte";
    import IndentSelect from "./IndentSelect.svelte";

    let langsPromise = loadLangs();

    let editorElement: HTMLElement;

    let editorView: EditorView;

    let line: number = 0;
    let pos: number = 0;

    let indentation = new Compartment();
    let tabSize = new Compartment();

    let selectedIndentUnit: [String, String];
    let selectedIndentAmount: [String, String];

    $: {
        if (editorView !== undefined) {
            setIndentation(selectedIndentUnit[1] as Unit, Number(selectedIndentAmount[1]));
        }
    }

    onMount(() => {
        let updateListener = EditorView.updateListener.of((update) => {
            let cmLine = update.state.doc.lineAt(
                update.state.selection.main.head
            );
            line = cmLine.number;
            pos = update.state.selection.main.head - cmLine.from;
        });

        editorView = new EditorView({
            state: EditorState.create({
                extensions: [
                    basicSetup,
                    keymap.of([indentWithTab]),
                    myst,
                    updateListener,
                    indentation.of(indentUnit.of("\t")),
                    tabSize.of(EditorState.tabSize.of(4)),
                ],
            }),
            parent: editorElement,
        });

        line = editorView.state.selection.main.head;
        pos = editorView.state.selection.main.from;
    });

    type Unit = "spaces" | "tabs";

    /**
     * Sets the indentation units and amount for the editor.
     */
    function setIndentation(unit: Unit, amount: number) {
        if (unit == "tabs") {
            editorView.dispatch({
                effects: [
                    indentation.reconfigure(indentUnit.of("\t")),
                    tabSize.reconfigure(EditorState.tabSize.of(amount)),
                ],
            });
        } else if (unit == "spaces") {
            editorView.dispatch({
                effects: indentation.reconfigure(
                    indentUnit.of(" ".repeat(amount))
                ),
            });
        }
    }

    /**
     * Loading all the languages from the API.
     */
    async function loadLangs(): Promise<[String, String][]> {
        // TODO: turn the host into a var
        let res = await fetch("http://localhost:5001/api/v3/data/langs", {
            headers: {
                "Content-Type": "application/json",
            },
        });

        let json: JSON = await res.json();

        let langs: [String, String][] = new Array<[String, String]>();

        for (let lang in json) {
            langs.push([lang, lang]);
        }

        return langs;
    }
</script>

<div class="editor" bind:this={editorElement} />

<div class="toolbar">
    <div class="left">
        {#await langsPromise}
            <p>loading...</p>
        {:then langs}
            <BigSelect
                id="language"
                label="lang:"
                placeholder="select a language..."
                options={langs}
            />
        {/await}
    </div>
    <div class="right">
        <div class="pos">
            ln {line} pos {pos}
        </div>
        <div class="indent">
            <IndentSelect
                bind:selectedIndentUnit={selectedIndentUnit}
                bind:selectedIndentAmount={selectedIndentAmount}
            />
        </div>
    </div>
</div>

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
        padding: 0em 1em;
        align-items: center;
    }

    .toolbar .right {
        display: flex;
        flex-direction: row;
    }

    .toolbar .right .pos {
        margin-right: 1em;
        align-self: center;
    }

    .toolbar .indent {
        display: flex;
        align-items: center;
    }
</style>
