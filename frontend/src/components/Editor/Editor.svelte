<script lang="ts">
    import { onMount, tick } from "svelte";
    import { EditorState, basicSetup } from "@codemirror/basic-setup";
    import { EditorView, keymap } from "@codemirror/view";
    import { Compartment } from "@codemirror/state";
    import { indentWithTab } from "@codemirror/commands";
    import { indentUnit, LanguageDescription, LanguageSupport } from "@codemirror/language";
    import { myst } from "../../themes/myst";
    import BigSelect from "../Input/PopupSelect.svelte";
    import IndentSelect from "../Input/IndentSelect.svelte";
    import { languages as codemirrorLangs } from "@codemirror/language-data";
    import type { Language } from "src/models/Language";

    type Unit = "spaces" | "tabs";

    export let hidden = false;
    export let langs: Map<string, Language>;
    export let langNames: [string, string][] = new Array<[string, string]>();
    // dont enable the lang select until the langs map has been converted to a proper structure
    let enableLangSelect: boolean = false;

    let editorElement: HTMLElement;

    let editorView: EditorView;

    let previewActive = false;
    let previewElement: HTMLElement;

    let line = 0;
    let pos = 0;

    let indentation = new Compartment();
    let tabSize = new Compartment();
    let language = new Compartment();

    let selectedIndentUnit: [string, string];
    let selectedIndentAmount: [string, string];

    let selectedLanguage: [string, string];
    let selectedFullLanguage: Language;

    $: {
        if (selectedLanguage !== undefined) {
            selectedFullLanguage = langs.get(selectedLanguage[1]);
        }
    }

    // if the lang highlighting is supported in codemirror
    let langSupported = false;

    onMount(async () => {
        await tick();

        for (const [k, v] of langs) {
            let val = "";
            if (v.aliases !== null) val = v.aliases.join(", ");
            langNames.push([val, k]);
        }

        // sort langs
        langNames.sort();

        // move plain text to the first position in the select
        let textIndex = langNames.findIndex((t) => t[1] === "Text");
        let textLang = langNames.splice(textIndex, 1)[0];
        langNames.unshift(textLang);

        // enable the lang select now that the langs map has been converted properly
        enableLangSelect = true;

        // set the editor language
        selectedLanguage = langNames[0];
        onLangSelected();

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
        const langName = selectedLanguage[1].toLowerCase();

        if (langName === "text") {
            langSupported = true;
            return;
        }

        let fullLangAliases: string[] = [];

        if (selectedFullLanguage.aliases !== null)
            fullLangAliases = selectedFullLanguage.aliases.map((a: string) => a.toLowerCase());
        // add the codemirrorMode to the aliases
        if (selectedFullLanguage.codemirrorMode !== null)
            fullLangAliases.push(selectedFullLanguage.codemirrorMode.toLowerCase());

        let langDescription: LanguageDescription = undefined;

        // check if the name matches
        for (let cmLang of codemirrorLangs) {
            if (langName === cmLang.name.toLowerCase()) {
                langDescription = cmLang;
                break;
            }
        }

        // check if one of the lang aliases matches the codemirror name
        if (langDescription === undefined) {
            for (let cmLang of codemirrorLangs) {
                if (fullLangAliases.includes(cmLang.name.toLowerCase())) {
                    langDescription = cmLang;
                    break;
                }
            }
        }

        // check if one of the lang aliases matches one of the codemirror aliases
        if (langDescription === undefined) {
            for (let cmLang of codemirrorLangs) {
                if (fullLangAliases.filter((a) => cmLang.alias.includes(a)).length > 0) {
                    langDescription = cmLang;
                    break;
                }
            }
        }

        let langSupport: LanguageSupport = undefined;

        if (langDescription !== undefined) langSupport = await langDescription.load();

        langSupported = langSupport !== undefined;

        editorView.dispatch({
            effects: language.reconfigure(langSupport)
        });
    };

    const onPreviewClick = async () => {
        previewActive = !previewActive;

        if (previewActive) {
            const data = {
                content: editorView.state.doc.toString(),
                languageName: selectedLanguage[1],
                languageScope: selectedFullLanguage.tmScope
            };

            const res = await fetch("/internal/highlight.json", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(data)
            });

            const html = (await res.json()).res;

            previewElement.innerHTML = html;
        }
    };
</script>

<div class:hidden>
    <div class="editor" bind:this={editorElement} class:hidden={previewActive}>
        <div class="not-supported-notice" class:hidden={langSupported}>
            <p>
                the language doesn't have highlighting in the editor, but will have
                it once the paste is created. use the preview button to see the final result.
            </p>
        </div>
    </div>

    <div class="preview" class:hidden={!previewActive} bind:this={previewElement} />

    <div class="toolbar">
        <div class="left">
            {#if enableLangSelect}
                <BigSelect
                    id="language"
                    label="lang:"
                    placeholder="select a language..."
                    options={langNames}
                    on:selected={onLangSelected}
                    bind:selectedValue={selectedLanguage}
                />
            {/if}
        </div>
        <div class="right">
            {#if selectedFullLanguage?.tmScope !== "none"}
                <div
                    class="preview-button toolbar-element"
                    class:active={previewActive}
                    on:click={onPreviewClick}
                >
                    preview
                </div>
            {/if}

            <div class="pos toolbar-element">
                ln {line} pos {pos}
            </div>

            <div class="indent toolbar-element">
                <IndentSelect
                    bind:selectedIndentUnit
                    bind:selectedIndentAmount
                    on:selected={onSetIndentation}
                />
            </div>
        </div>
    </div>
</div>

<style lang="scss">
    .hidden {
        display: none;
    }

    .editor {
        height: 50vh;
        position: relative;

        .not-supported-notice {
            position: absolute;
            bottom: 0;
            z-index: 100;
            width: 100%;
            padding: 0.5em;
            user-select: none;
            font-size: var(--fontsize-small);

            p {
                background-color: var(--color-accent);
                color: var(--color-cod-gray);
                border-radius: var(--border-radius);
                padding: 0.5em 1em;
                margin: 0;
            }
        }
    }

    .preview {
        height: 50vh;
        overflow: auto;
        background-color: var(--color-cod-gray-light);
    }

    .toolbar {
        background-color: var(--color-mineshaft);
        border-radius: 0 0 var(--border-radius) var(--border-radius);
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        padding: 0em 1em;
        align-items: center;

        .right {
            display: flex;
            flex-direction: row;
            align-items: center;
        }

        .toolbar-element {
            margin-right: 1em;
            padding: 0.25em 0.5em;

            &:last-child {
                margin-right: 0;
            }
        }

        .preview-button {
            cursor: pointer;
            user-select: none;

            &:hover {
                background-color: var(--color-cod-gray);
            }

            &.active {
                background-color: var(--color-accent);
                color: var(--color-cod-gray);
            }
        }

        .pos {
            align-self: center;
        }

        .indent {
            display: flex;
            align-items: center;
        }
    }
</style>
