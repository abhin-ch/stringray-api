using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;

namespace StingrayNET.Api.Controllers;

[Authorize]
[EnableCors("stingrayCORS")]
[ApiController]
public abstract class BaseApiController : ControllerBase
{
    protected readonly IIdentityService _identityService;
    public BaseApiController(IIdentityService identityService)
    {
        _identityService = identityService;
    }
}