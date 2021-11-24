module model.visibility;

/** 
 * Visibility of a paste.
 */
public enum Visibility : string
{
    // public, not on profile
    pub = "public",
    // only visible by the author
    priv = "private",
    // visible on authors public profile
    profile = "profile",
}
