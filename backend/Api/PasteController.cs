using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PasteMyst.Models;
using PasteMyst.Services;

namespace PasteMyst.Api
{
    /// <summary>
    ///     Endpoint for fetching and creating pastes.
    /// </summary>
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

        /// <summary>
        ///     Get a paste by its ID.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<Paste>> Get(string id)
        {
            Paste p = await _pasteService.Get(id);

            if (p is null) return NotFound();

            return p;
        }

        /// <summary>
        ///     Create a paste.
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<Paste>> Create(PasteSkeleton skeleton)
        {
            try
            {
                Paste paste = await _pasteService.Create(skeleton);

                return CreatedAtAction(nameof(Get), new {id = paste.Id}, paste);
            }
            catch (NotImplementedException ex)
            {
                // TODO: should be removed once everything is implemented
                return StatusCode(StatusCodes.Status501NotImplemented, new {message = ex.Message});
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new {message = ex.Message});
            }
        }
    }
}
