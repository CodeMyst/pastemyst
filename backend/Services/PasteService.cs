using System;
using MongoDB.Driver;
using PasteMyst.Models;

namespace PasteMyst.Services
{
    /// <summary>
    /// CRUD Service for pastes.
    /// </summary>
    public class PasteService
    {
        private readonly IMongoCollection<Paste> _pastes;

        public PasteService(IDatabaseSettings settings)
        {
            MongoClient client = new MongoClient(settings.ConnectionString);
            IMongoDatabase db = client.GetDatabase(settings.DatabaseName);

            _pastes = db.GetCollection<Paste>(settings.PasteCollectionName);
        }

        public Paste Get(string id)
        {
            return _pastes.Find<Paste>(p => p.Id == id).FirstOrDefault();
        }

        public Paste Create(Paste paste)
        {
            _pastes.InsertOne(paste);
            return paste;
        }
    }
}