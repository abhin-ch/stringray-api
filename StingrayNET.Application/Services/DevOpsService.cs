using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common.DevOps;
using StingrayNET.ApplicationCore.Requests;

namespace StingrayNET.Application.Services;

public interface IDevOpsService
{
    public Task<ActionResult<string>> SendAddWIRequest(SubmitFeedbackRequest request, HttpContext context);

}

public class DevOpsService : IDevOpsService
{
    private readonly IDevopsService DevopsService;

    public DevOpsService(IDevopsService devopsService)
    {
        DevopsService = devopsService;
    }

    public async Task<ActionResult<string>> SendAddWIRequest(SubmitFeedbackRequest request, HttpContext context)
    {
        var subrequest = request.AddWISubrequests.Select(e => new AddWISubrequest(e.op, e.path, e.value)).ToList();
        var addwiRequest = new AddWIRequest(request.WIType, request.Module, subrequest);
        return await DevopsService.SendAddWIRequest(addwiRequest, context);
    }
}