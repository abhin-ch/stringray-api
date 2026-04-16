using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using System.Net;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.Feedback;
using Microsoft.AspNetCore.Cors;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[ModuleRoute("api/[controller]", ModuleEnum.Admin)]
[EnableCors("stingrayCORS")]
[ApiController]
//[Authorize]
public class FeedbackController : ControllerBase
{
    private readonly IRepositoryS<FeedbackProcedure, FeedbackResult> _repository;

    public FeedbackController(IRepositoryS<FeedbackProcedure, FeedbackResult> repository)
    {
        _repository = repository;
    }

    //POST api/[controller/create
    [Route("create")]
    [HttpPost]
    public async Task<JsonResult> CreateFeedback([FromBody] FeedbackProcedure model)
    {
        if (model == null)
        {
            return BaseResult.JsonResult<HttpError>("Feedback is empty");
        }
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/[controller/addressed
    [Route("addressed")]
    [HttpPut]
    public async Task<JsonResult> FeedbackAddressed(int feedbackID)
    {
        var model = new FeedbackProcedure
        {
            Num1 = feedbackID,
        };
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/[controller]
    [HttpGet]
    public async Task<JsonResult> GetFeedback()
    {
        var result = await _repository.Op_03();
        return BaseResult.JsonResult(result);
    }

    //PATCH api/[controller/updateStatus
    [Route("updateStatus")]
    [HttpPatch]
    public async Task<JsonResult> UpdateStatus(int feedbackID, string status)
    {
        var model = new FeedbackProcedure
        {
            Num1 = feedbackID,
            Value1 = status
        };
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/[controller]/updateAddressedBy
    [Route("updateAddressedBy")]
    [HttpPatch]
    public async Task<JsonResult> UpdateAddressedBy(int feedbackID, string addressedBy)
    {
        var model = new FeedbackProcedure
        {
            Num1 = feedbackID,
            Value1 = addressedBy
        };
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    [Route("getImages")]
    [HttpGet]
    public async Task<JsonResult> GetImages(int feedbackID)
    {
        var model = new FeedbackProcedure
        {
            Num1 = feedbackID,
        };
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }
}
