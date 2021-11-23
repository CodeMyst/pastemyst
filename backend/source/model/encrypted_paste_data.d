module model.encrypted_paste_data;

import model;

/** 
 * Used for serialization of paste data into JSON before encryption;
 */
public class EncryptedPasteData
{
    /** 
     * Paste's title.
     */
    public string title;

    /** 
     * Paste's files.
     */
    public Pasty[] pasties;
}
