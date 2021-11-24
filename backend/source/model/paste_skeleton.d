module model.paste_skeleton;

import vibe.d;
import model;

/**
 * This object is passed to the API to create a full Paste object.
 */
public class PasteSkeleton
{
    /**
     * Paste's title.
     */
    @optional
    public string title = "";

    /**
     * When the paste expires.
     */
    @optional
    public ExpiresIn expiresIn = ExpiresIn.never;

    /** 
     * Visibility of the paste.
     */
    @optional
    public Visibility visibility = Visibility.pub;

    /**
     * Tags of the paste, only if it's an owned paste.
     */
    @optional
    public string[] tags;

    /**
     * Paste's files.
     */
    public Pasty[] pasties;
}
