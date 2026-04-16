using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.ApplicationCore.Models.Common.DevOps;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Requests;
using StingrayNET.Application.Services;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class DevopsController : ControllerBase
{
    private readonly IDevopsService _DevopsService;

    private readonly IDevOpsService _DevOpsService;

    public DevopsController(IDevopsService devopsService, IDevOpsService devOpsService)
    {
        _DevopsService = devopsService;
        _DevOpsService = devOpsService;
    }

    [HttpPost]
    [Route("wi/add")]
    public async Task<ActionResult<string>> AddWI(SubmitFeedbackRequest request)
    {
        return await _DevOpsService.SendAddWIRequest(request, HttpContext);

    }

    [HttpPost]
    [Route("wi/attachment")]
    public async Task<ActionResult<string>> AddAttachment(IFormFile file)
    {
        AddAttachmentRequest addAttachmentRequest = new AddAttachmentRequest();
        addAttachmentRequest.FileName = file.FileName;
        return await _DevopsService.AddAttachment(addAttachmentRequest, file.OpenReadStream());

    }

    [HttpPost]
    [Route("wi/link-attachment")]
    public async Task<JsonResult> LinkAttachment([FromBody] LinkAttachmentRequest linkAttachmentRequest)
    {
        var result = await _DevopsService.LinkAttachment(linkAttachmentRequest);
        return BaseResult.JsonResult<HttpSuccess>(result);
    }

}