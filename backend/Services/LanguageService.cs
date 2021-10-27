using System.Collections.Generic;
using System.Linq;
using PasteMyst.Models;

namespace PasteMyst.Services
{
    public class LanguageService
    {
        private readonly Dictionary<string, Language> _langs;

        public LanguageService(Dictionary<string, Language> langs)
        {
            _langs = langs;
        }

        /// <summary>
        ///     Finds the language based on the provided name, alias or extension.
        /// </summary>
        /// <returns>The proper language name. Returns null if the language isn't found.</returns>
        public string GetLanguage(string lang)
        {
            foreach ((string key, Language value) in _langs)
            {
                // by name
                if (key.ToLower().Equals(lang.ToLower())) return key;

                // by alias
                if (value.Aliases is not null && value.Aliases.Length > 0)
                    if (value.Aliases.Any(alias => alias.ToLower().Equals(lang.ToLower())))
                        return key;

                // by extension
                if (value.Extensions is not null && value.Extensions.Length > 0)
                    if (value.Extensions.Any(ext => ext.TrimStart('.').ToLower().Equals(lang.ToLower())))
                        return key;
            }

            return null;
        }
    }
}
