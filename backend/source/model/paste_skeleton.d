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
     * If the paste is private only the owner can open it.
     */
    @optional
    public bool isPrivate = false;

    /**
     * If the paste is public, it will get shown on the owner's profile.
     */
    @optional
    public bool isShowOnProfile = false;

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
