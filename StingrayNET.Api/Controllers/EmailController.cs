using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System.Text.Json;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ApiController]
[EnableCors("stingrayCORS")]
[Route("api/[controller]")]
public class EmailController : ControllerBase
{
#nullable disable

    private readonly IEmailService _emailService;
    private readonly IIdentityService _identityService;

    public EmailController(IEmailService emailService, IIdentityService identityService)
    {
        _emailService = emailService;
        _identityService = identityService;
    }

    // POST /api/email/send
    [HttpPost]
    [Route("send")]
    public async Task<JsonResult> SendEmail([FromBody] Procedure body)
    {
        try
        {
            var toList = JsonSerializer.Deserialize<List<string>>(body.Value1);
            List<string> ccList = null;
            List<string> bccList = null;
            if (body.Value4 is not null)
            {
                ccList = JsonSerializer.Deserialize<List<string>>(body.Value4);
            }
            if (body.Value5 is not null)
            {
                bccList = JsonSerializer.Deserialize<List<string>>(body.Value5);
            }
            var emailTemplate = new EmailTemplate(toList, body.Value2, body.Value3, CCList: ccList, BCCList: bccList);
            var result = await _emailService.Send(emailTemplate);
            return BaseResult.JsonResult<HttpSuccess>(result);
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(e.Message);
        }

    }

    // POST /api/email/download
    [HttpPost]
    [Route("download")]
    public async Task<ActionResult> DownloadEmail([FromBody] Procedure body)
    {
        var fromEmail = (await _identityService.GetUser(HttpContext)).Email;
        var emailTemplate = new MsgTemplate(fromEmail,
            toAddress: new List<string> { body.Value1 },
            subject: body.Value2,
            htmlBody: body.Value3,
            ccAddress: new List<string> { body.Value4 },
            bccAddress: new List<string> { body.Value5 });
        return await _emailService.Download(emailTemplate, body.Value6);
    }
#nullable enable

}
