namespace PasteMyst.Models
{
    // TODO: Explain somewhere how pastemyst's encryption system works.

    /// <summary>
    /// Encrypted paste object.
    /// </summary>
    public class EncryptedPaste : BasePaste
    {
        /// <summary>
        /// Holds the pasty objects and the title, serialized to json and encrypted.
        /// </summary>
        public string EncryptedData { get; set; }

        /// <summary>
        /// The key used to encrypt the data, the key itself is also encrypted.
        /// </summary>
        public string EncryptedKey { get; set; }

        /// <summary>
        /// Salt.
        /// </summary>
        public string Salt { get; set; }
    }
}