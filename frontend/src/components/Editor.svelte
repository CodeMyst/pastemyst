<script lang="ts">
    import { onMount, tick } from "svelte";
    import { EditorState, basicSetup } from "@codemirror/basic-setup";
    import { EditorView, keymap } from "@codemirror/view";
    import { Compartment } from "@codemirror/state";
    import { indentWithTab } from "@codemirror/commands";
    import { indentUnit, LanguageDescription, LanguageSupport } from "@codemirror/language";
    import { myst } from "../cm-themes/myst";
    import BigSelect from "./BigSelect.svelte";
    import IndentSelect from "./IndentSelect.svelte";
    import { getLanguage, getLanguageNames } from "../langs";
    import { languages as codemirrorLangs } from "@codemirror/language-data";

    type Unit = "spaces" | "tabs";

    export let hidden = false;

    let langsPromise = getLanguageNames();

    let editorElement: HTMLElement;

    let editorView: EditorView;

    let line = 0;
    let pos = 0;

    let indentation = new Compartment();
    let tabSize = new Compartment();
    let language = new Compartment();

    let selectedIndentUnit: [string, string];
    let selectedIndentAmount: [string, string];

    let selectedLanguage: [string, string];

    onMount(async () => {
        let updateListener = EditorView.updateListener.of((update) => {
            let cmLine = update.state.doc.lineAt(update.state.selection.main.head);
            line = cmLine.number;
            pos = update.state.selection.main.head - cmLine.from;
        });

        await tick();

        editorView = new EditorView({
            state: EditorState.create({
                extensions: [
                    basicSetup,
                    keymap.of([indentWithTab]),
                    myst,
                    updateListener,
                    indentation.of(indentUnit.of("\t")),
                    tabSize.of(EditorState.tabSize.of(4)),
                    language.of([])
                ]
            }),
            parent: editorElement
        });

        line = editorView.state.selection.main.head;
        pos = editorView.state.selection.main.from;

        onSetIndentation();
    });

    export const focus = (): void => {
        editorView.focus();
    };

    /**
     * Sets the indentation units and amount for the editor.
     */
    const onSetIndentation = () => {
        const unit = selectedIndentUnit[1] as Unit;
        const amount = Number(selectedIndentAmount[1]);

        if (unit == "tabs") {
            editorView.dispatch({
                effects: [
                    indentation.reconfigure(indentUnit.of("\t")),
                    tabSize.reconfigure(EditorState.tabSize.of(amount))
                ]
            });
        } else if (unit == "spaces") {
            editorView.dispatch({
                effects: indentation.reconfigure(indentUnit.of(" ".repeat(amount)))
            });
        }
    };

    /**
     * Sets the proper language of the editor.
     */
    const onLangSelected = async () => {
        const fullLang = await getLanguage(selectedLanguage[1] as string);
        const langName = selectedLanguage[1].toLowerCase();

        let fullLangAliases: string[] = [];

        if (fullLang.aliases !== null)
            fullLangAliases = fullLang.aliases.map((a) => a.toLowerCase());
        // add the codemirrorMode to the aliases
        if (fullLang.codemirrorMode !== null)
            fullLangAliases.push(fullLang.codemirrorMode.toLowerCase());

        let langDescription: LanguageDescription = undefined;

        for (let cmLang of codemirrorLangs) {
            // check if the name matches
            if (langName === cmLang.name.toLowerCase()) {
                langDescription = cmLang;
                break;
            }
            // check if one of the lang aliases matches the codemirror name
            else if (fullLangAliases.includes(cmLang.name.toLowerCase())) {
                langDescription = cmLang;
                break;
            }
            // check if one of the lang aliases matches one of the codemirror aliases
            else if (fullLangAliases.filter((a) => cmLang.alias.includes(a)).length > 0) {
                langDescription = cmLang;
                break;
            }
        }

        let langSupport: LanguageSupport = undefined;

        if (langDescription !== undefined) langSupport = await langDescription.load();

        editorView.dispatch({
            effects: language.reconfigure(langSupport)
        });
    };
</script>

<div class:hidden>
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
                    on:selected={onLangSelected}
                    bind:selectedValue={selectedLanguage}
                />
            {/await}
        </div>
        <div class="right">
            <div class="pos">
                ln {line} pos {pos}
            </div>
            <div class="indent">
                <IndentSelect
                    bind:selectedIndentUnit
                    bind:selectedIndentAmount
                    on:selected={onSetIndentation}
                />
            </div>
        </div>
    </div>
</div>

<style>
    .hidden {
        display: none;
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

    .editor {
        height: 50vh;
    }
</style>
