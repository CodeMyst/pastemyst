module model.language;

import yamlserialized;
import model;

public class Language
{
    /**
     * Type of language. Either data, programming, markup, prose or nil.
     */
    public LanguageType type;

    /**
     * Array of additional aliases.
     */
    public string[] aliases;

    /**
     * String name of the CodeMirror mode used for the editor.
     */
    @YamlField("codemirror_mode")
    public string codemirrorMode;

    /**
     * String name of the file mime type used for the CodeMirror editor.
     */
    @YamlField("codemirror_mime_type")
    public string codemirrorMimeType;

    /**
     * Array of extensions associated with the language. The first one is considered the primary extension.
     */
    public string[] extensions;

    /**
     * Array of common filenames associated with the language.
     */
    public string[] filenames;

    /**
     * CSS hex color representing the languages.
     */
    public string color;

    /**
     * Name of the parent language. Languages in a group are counted in the stats as the parent language.
     */
    public string group;

    /**
     * The TextMate scope that represents this programming language.
     */
    @YamlField("tm_scope")
    public string tmScope;
}
