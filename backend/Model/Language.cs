using YamlDotNet.Serialization;

namespace PasteMyst.Model
{
    public class Language
    {
        /// <summary>
        /// Type of language. Either data, programming, markup, prose or nil.
        /// <seealso cref="PasteMyst.Model.LanguageType"/>
        /// </summary>
        public LanguageType Type { get; set; }
        
        /// <summary>
        /// Array of additional aliases.
        /// </summary>
        public string[] Aliases { get; set; }
        
        /// <summary>
        /// String name of the CodeMirror mode used for the editor.
        /// </summary>
        [YamlMember(Alias = "codemirror_mode")]
        public string CodemirrorMode { get; set; }
        
        /// <summary>
        /// String name of the file mime type used for the CodeMirror editor.
        /// </summary>
        [YamlMember(Alias = "codemirror_mime_type")]
        public string CodemirrorMimeType {get; set; }
        
        /// <summary>
        /// Array of extensions associated with the language. The first one is considered the primary extension.
        /// </summary>
        public string[] Extensions { get; set; }
        
        /// <summary>
        /// Array of common filenames associated with the language.
        /// </summary>
        public string[] Filenames { get; set; }
        
        /// <summary>
        /// CSS hex color representing the languages.
        /// </summary>
        public string Color { get; set; }
        
        /// <summary>
        /// Name of the parent language. Languages in a group are counted in the stats as the parent language.
        /// </summary>
        public string Group { get; set; }
    }
}