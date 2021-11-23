module model.pasty;

import vibe.d;

/**
 * Represents a single file in a paste.
 */
public class Pasty
{
    /**
     * Pasty ID.
     */
    @optional
    @name("_id")
    public string id = "";

    /**
     * Pasty's title.
     */
    @optional
    public string title = "";

    /**
     * Pasty's language name.
     */
    public string language;

    /**
     * Pasty's contents.
     */
    public string content;
}
