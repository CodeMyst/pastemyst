module pastemyst.model.language;

import yamlserialized;

/**
 * Language supported by pastemyst
 */
public struct Language
{
    /**
     * Type of language
     */
    LanguageType type;

    /**
     * Array of additional aliases
     */
    string[] aliases;

    /**
     * A string name of the CodeMirror mode used for the editor
     */
    @YamlField("codemirror_mode")
    string codemirrorMode;

    /**
     * A string name of the file mime type used for the editor
     */
    @YamlField("codemirror_mime_type")
    string codemirrorMimeType;

    /**
     * Array of associated extensions, the first one should be considered the primary
     */
    string[] extensions;

    /**
     * Array of filenames commonly associated with the language
     */
    string[] filenames;

    /**
     * CSS hex color representing the language
     */
    string color;

    /**
     * Name of the parent language, languages in a group are counted in the statistics
     * as the parent language
     */
    string group;
}

/**
 * Type of a language
 */
public enum LanguageType
{
    data,
    programming,
    markup,
    prose,
    nil
}
