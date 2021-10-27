namespace PasteMyst.Models
{
    /// <summary>
    ///     Settings for connecting to the MongoDB.
    /// </summary>
    public class DatabaseSettings : IDatabaseSettings
    {
        public string PasteCollectionName { get; set; }

        public string ConnectionString { get; set; }

        public string DatabaseName { get; set; }
    }

    public interface IDatabaseSettings
    {
        string PasteCollectionName { get; set; }

        string ConnectionString { get; set; }

        string DatabaseName { get; set; }
    }
}
