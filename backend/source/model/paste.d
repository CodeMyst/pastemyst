module model.paste;

import model;

/**
 * Regular paste object.
 */
public class Paste : BasePaste
{
    /**
     * Paste's title.
     */
    public string title;

    /**
     * Paste's files.
     */
    public Pasty[] pasties;

    /**
     * Array of paste edits.
     */
    public Edit[] edits;
}
