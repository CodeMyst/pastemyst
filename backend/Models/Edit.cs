using MongoDB.Bson.Serialization.Attributes;

namespace PasteMyst.Models
{
    /// <summary>
    /// Holds information about a single paste edit.
    /// </summary>
    public class Edit
    {
        /// <summary>
        /// Edit ID.
        /// </summary>
        [BsonId]
        public string Id { get; set; }

        /// <summary>
        /// Multiple edits with the same GroupId means that they were edited all at once.
        /// </summary>
        public string GroupId { get; set; }

        /// <summary>
        /// Type of edit.
        /// </summary>
        public EditType Type { get; set; }

        /// <summary>
        /// General storage for edits. Most used case is for storing which pasty was edited.
        /// </summary>
        public string[] Metadata { get; set; }

        /// <summary>
        /// Actual edit changes, usually stores the previous paste data, as the current paste holds the new data.
        /// </summary>
        public string Change { get; set; }

        /// <summary>
        /// When the edit was done, unix time.
        /// </summary>
        public ulong EditedAt { get; set; }
    }
}
