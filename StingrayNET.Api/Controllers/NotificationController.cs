using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class NotificationController : ControllerBase
{
    private readonly IRepositoryS<NotificationProcedure, NotificationResult> _repo;

    public NotificationController(IRepositoryS<NotificationProcedure, NotificationResult> repo)
    {
        _repo = repo;
    }

    [HttpGet]
    [AppSecurity("NotificationGeneral")]
    public async Task<JsonResult> GetNotifications()
    {
        return new JsonResult((await _repo.Op_01()));
    }

    [HttpPut]
    [Route("add")]
    [AppSecurity("NotificationGeneral")]
    public async Task<JsonResult> AddNotification([FromBody] NotificationProcedure model)
    {
        return new JsonResult((await _repo.Op_02(model)));

    }

    [HttpPut]
    [Route("address")]
    [AppSecurity("NotificationGeneral")]
    public async Task<JsonResult> AddressNotification([FromBody] NotificationProcedure model)
    {
        return new JsonResult((await _repo.Op_03(model)));
    }

}