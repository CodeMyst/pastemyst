using Microsoft.AspNetCore.Mvc;
using PasteMyst.Models;
using PasteMyst.Services;

namespace PasteMyst.Api
{
    [ApiController]
    [Produces("application/json")]
    [ApiVersion("3")]
    [Route("api/v{version:apiVersion}/[controller]")]
    public class PasteController : ControllerBase
    {
        private readonly PasteService _pasteService;

        public PasteController(PasteService pasteService)
        {
            _pasteService = pasteService;
        }

        [HttpGet("{id}")]
        public ActionResult<Paste> Get(string id)
        {
            Paste p = _pasteService.Get(id);

            if (p is null) return NotFound();

            return p;
        }

        [HttpPost]
        public ActionResult<Paste> Create(Paste paste)
        {
            _pasteService.Create(paste);

            return CreatedAtAction(nameof(Get), new { id = paste.Id.ToString() }, paste);
        }
    }
}