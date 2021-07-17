module pastemyst.data.files;

import dyaml;
import yamlserialized;
import vibe.d;
import pastemyst.model;

/**
 * List of all supported languages as an AA.
 */
public Language[string] langs() { return _langs; }
private Language[string] _langs;

/**
 * Enum that defines all possible data files.
 */
public enum DataFile
{
    languages = "languages.yml"
}

static this()
{
    Node node = Loader.fromFile("data/" ~ DataFile.languages).load();

    node.deserializeInto(_langs);
}
