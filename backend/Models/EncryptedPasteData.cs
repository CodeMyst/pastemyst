namespace PasteMyst.Models
{
    /// <summary>
    /// Used for serialization of paste data into JSON before encryption.
    /// </summary>
    public class EncryptedPasteData
    {
        /// <summary>
        /// Paste's title.
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// Paste's files.
        /// </summary>
        public Pasty[] Pasties { get; set; }
    }
}