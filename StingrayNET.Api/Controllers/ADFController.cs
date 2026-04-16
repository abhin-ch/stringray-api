using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.ApplicationCore.Models.Common.ADF;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.Common;
using Microsoft.AspNetCore.Cors;
using Newtonsoft.Json;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ApiController]
[EnableCors("stingrayCORS")]
[ModuleRoute("api/[controller]", ModuleEnum.Common)]
public class ADFController : ControllerBase
{
    private readonly IADFService _ADFService;
    private readonly IIdentityService _identityService;

    public ADFController(IADFService adfService, IIdentityService identityService)
    {
        _ADFService = adfService;
        _identityService = identityService;
    }

    //POST api/adf/request
    [HttpPost]
    [Route("request")]
    public async Task<JsonResult> TriggerPipeline([FromBody] Procedure model)
    {
        try
        {
            if (string.IsNullOrEmpty(model.Value1))
                return BaseResult.JsonResult<HttpError>($"ADFPipelineRequest [ERR]: Value1 in body cannot be null. ADF Pipeline name required.");
            var request = new TriggerRequest(model.Value1);
            if (!string.IsNullOrEmpty(model.Value2))
            {
                var values = JsonConvert.DeserializeObject<Dictionary<string, object>>(model.Value2);
                request = new TriggerRequest(model.Value1, values);
            }
            var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
            request.AddEmployeeID(employeeID);

            var duration = await _ADFService.TriggerPipeline(request);
            return BaseResult.JsonResult<HttpSuccess>(string.Format(@"Pipeline {0} successfully executed after {1} seconds", request.PipelineName, duration));
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>($"ADFPipelineRequest [ERR]: {e.Message}");
        }

    }

}

