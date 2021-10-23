using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace PasteMyst.Models
{
    /// <summary>
    /// Paste and EncryptedPaste inherit this object.
    /// </summary>
    public class BasePaste
    {
        /// <summary>
        /// Paste ID.
        /// </summary>
        [BsonId]
        public string Id { get; set; }

        /// <summary>
        /// When the paste is created, unix time.
        /// </summary>
        public ulong CreatedAt { get; set; }

        /// <summary>
        /// When the paste expires.
        /// </summary>
        public ExpiresIn ExpiresIn { get; set; }

        /// <summary>
        /// When the paste will get deleted, if ExpiresIn is set to Never, this value is set to 0.
        /// </summary>
        public ulong DeletesAt { get; set; }

        /// <summary>
        /// Owner's ID of the paste. If no owner then this value is null.
        /// </summary>
        public string OwnerId { get; set; }

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
        /// Number of stars.
        /// </summary>
        public ulong Stars { get; set; }

        /// <summary>
        /// Whether the is encrypted.
        /// </summary>
        /// <value></value>
        public bool IsEncrypted { get; set; }
    }
}