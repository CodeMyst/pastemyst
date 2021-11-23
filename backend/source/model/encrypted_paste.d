module model.encrypted_paste;

import model;

// TODO: Explain somewhere how pastemyst's encryption system works.

/** 
 * Encrypted paste object.
 */
public class EncryptedPaste : BasePaste
{
    /** 
     * Holds the pasty objects and the title, serialized to json and encrypted;
     */
    public string encryptedData;

    /** 
     * The key used to encrypt the data, the key itself is also encrypted.
     */
    public string encryptedKey;

    /** 
     * Salt.
     */
    public string salt;
}
