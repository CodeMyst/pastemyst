using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace PasteMyst.Models
{
    /// <summary>
    /// Represents a single file in a paste.
    /// </summary>
    public class Pasty
    {
        /// <summary>
        /// Pasty ID.
        /// </summary>
        [BsonId]
        public string Id { get; set; } = "";

        /// <summary>
        /// Pasty's title.
        /// </summary>
        public string Title { get; set; }

        /// <summary>
        /// Pasty's language name.
        /// </summary>
        public string Language { get; set; }

        /// <summary>
        /// Pasty's contents.
        /// </summary>
        public string Contents { get; set; }
    }
}