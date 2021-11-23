module model.base_paste;

import std.datetime;
import std.typecons;
import vibe.d;
import model;

/** 
 * Paste and EncryptedPaste inherit this object.
 */
public class BasePaste
{
    /** 
     * Paste ID.
     */
    @name("_id")
    public string id;

    /** 
     * When the paste is created.
     */
    public DateTime createdAt;

    /** 
     * When the paste will get deleted, if expiresIn is set to Never, this value is set to null.
     */
    public Nullable!DateTime deletesAt;

    /** 
     * When the paste expires.
     */
    public ExpiresIn expiresIn;

    /** 
     * Owner's ID of the paste. If no owner then this value is null.
     */
    public string ownerId;

    /** 
     * If the paste is private only the owner can open it.
     */
    public bool isPrivate;

    /** 
     * Whether the paste will get shown on the owner's profile.
     */
    public bool isShowOnProfile;

    /** 
     * Tags of the paste, only if it's an owned paste.
     */
    public string[] tags;

    /** 
     * Number of stars.
     */
    public ulong stars;

    /** 
     * Whether the paste is encrypted.
     */
    public bool isEncrypted;
}
