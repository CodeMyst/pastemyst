namespace PasteMyst.Models
{
    /// <summary>
    /// Regular paste object.
    /// </summary>
    public class Paste : BasePaste
    {
        /// <summary>
        /// Paste's title.
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// Paste's files.
        /// </summary>
        public Pasty[] Pasties { get; set; }

        /// <summary>
        /// Array of paste edits.
        /// </summary>
        public Edit[] Edits { get; set; }
    }
}