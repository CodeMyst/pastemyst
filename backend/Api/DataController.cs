using System.Collections.Generic;
using Microsoft.AspNetCore.Mvc;
using PasteMyst.Models;

namespace PasteMyst.Api
{
    [ApiController]
    [Produces("application/json")]
    [ApiVersion("3")]
    [Route("api/v{version:apiVersion}/[controller]")]
    public class DataController : ControllerBase
    {
        private readonly Dictionary<string, Language> _langs;

        public DataController(Dictionary<string, Language> langs)
        {
            _langs = langs;
        }

        [HttpGet]
        [Route("langs")]
        public ActionResult<Dictionary<string, Language>> GetLanguages()
        {
            return _langs;
        }
    }
}