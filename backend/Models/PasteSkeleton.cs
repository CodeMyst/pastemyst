namespace PasteMyst.Models
{
    /// <summary>
    /// This object is passed to the API to create a full Paste object.
    /// </summary>
    public class PasteSkeleton
    {
        /// <summary>
        /// Paste's title.
        /// </summary>
        public string Title { get; set; } = "";

        /// <summary>
        /// When the paste expires.
        /// </summary>
        public ExpiresIn ExpiresIn { get; set; }

        /// <summary>
        /// If the paste is private only the owner can open it.
        /// </summary>
        public bool IsPrivate { get; set; }

        /// <summary>
        /// If the paste is public, it will get shown on the owner's profile.
        /// </summary>
        public bool IsPublic { get; set; }

        /// <summary>
        /// Tags of the paste, only if it's an owned paste.
        /// </summary>
        public string[] Tags { get; set; }

        /// <summary>
        /// Paste's files.
        /// </summary>
        public Pasty[] Pasties { get; set; }
    }
}