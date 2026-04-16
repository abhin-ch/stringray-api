using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.STMS;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class STMSController : ControllerBase
{
    private readonly IRepositoryS<Procedure, STMSResult> _repository;

    public STMSController(IRepositoryS<Procedure, STMSResult> repository)
    {

        _repository = repository;
    }


    //GET api/stms/legacy-attachment-upload
    [AllowAnonymous]
    [HttpGet]
    [Route("legacy-attachment-upload")]
    public async Task UploadLegacyFile()
    {
        await _repository.Op_01();
    }
}