using System;
using System.Threading.Tasks;
using MongoDB.Driver;
using PasteMyst.Models;
using PasteMyst.Utils;

namespace PasteMyst.Services
{
    /// <summary>
    /// CRUD Service for pastes.
    /// </summary>
    public class PasteService
    {
        private readonly IMongoCollection<Paste> _pastes;
        private readonly LanguageService _langService;

        public PasteService(IDatabaseSettings settings, LanguageService langService)
        {
            var client = new MongoClient(settings.ConnectionString);
            IMongoDatabase db = client.GetDatabase(settings.DatabaseName);

            _pastes = db.GetCollection<Paste>(settings.PasteCollectionName);

            _langService = langService;
        }

        public async Task<Paste> Get(string id)
        {
            // TODO: check if current time > expiration time just in case
            return (await _pastes.FindAsync(p => p.Id.Equals(id))).FirstOrDefault();
        }

        public async Task<bool> Exists(string id)
        {
            return await (await _pastes.FindAsync(p => p.Id.Equals(id))).AnyAsync();
        }

        public async Task<Paste> Create(PasteSkeleton skeleton)
        {
            if (skeleton.IsPublic || skeleton.IsPrivate || (skeleton.Tags is not null && skeleton.Tags.Length > 0))
            {
                throw new NotImplementedException("account pastes not yet implemented.");
            }

            if (skeleton.Pasties is null || skeleton.Pasties.Length == 0)
            {
                throw new ArgumentException("pasties array has to have at least one pasty.");
            }

            foreach (Pasty pasty in skeleton.Pasties)
            {
                if (pasty.Language is null) throw new ArgumentException("all pasties must have a language");
                if (pasty.Content is null) throw new ArgumentException("all pasties must have content");

                string langName = _langService.GetLanguage(pasty.Language);

                if (langName is null) throw new ArgumentException($"invalid pasty language: ${pasty.Language}.");

                pasty.Language = langName;
            }

            DateTime createdAt = DateTime.Now;
            DateTime? deletesAt = ExpiresUtils.GetDeletionTime(createdAt, skeleton.ExpiresIn);

            // TODO: user pastes
            // TODO: encrypted pastes

            var res = new Paste()
            {
                Id = await RandomPasteId(),
                CreatedAt = DateTime.Now,
                ExpiresIn = skeleton.ExpiresIn,
                DeletesAt = deletesAt,
                Title = skeleton.Title,
                OwnerId = "",
                IsPrivate = false,
                IsPublic = false,
                IsEncrypted = false,
                Tags = Array.Empty<string>(),
                Edits = Array.Empty<Edit>(),
            };

            foreach (Pasty pasty in skeleton.Pasties)
            {
                pasty.Id = await RandomPastyId(res);

                // TODO: autodetect

                pasty.Content = pasty.Content.Replace("\r\n", "\n");
            }

            res.Pasties = skeleton.Pasties;

            await _pastes.InsertOneAsync(res);

            return res;
        }

        private async Task<string> RandomPasteId() => await IdUtils.RandomIdPred(async (id) => await Exists(id));

        private async Task<string> RandomPastyId(Paste p)
        {
            if (p.Pasties is null) return IdUtils.RandomId();

            return await IdUtils.RandomIdPred((id) => Task.FromResult(Array.Exists(p.Pasties, p => p.Id.Equals(id))));
        }
    }
}
