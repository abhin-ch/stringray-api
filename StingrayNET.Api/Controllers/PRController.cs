using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.PR;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class PRController : ControllerBase
{
    private readonly IRepositoryM<PRProcedure, PRResult> _repository;

    public PRController(IRepositoryM<PRProcedure, PRResult> repository)
    {
        _repository = repository;
    }

    //PATCH api/pr/apt
    [HttpPatch]
    [Route("apt")]
    public async Task<JsonResult> SaveAPT([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/add-item
    [HttpPost]
    [Route("add-item")]
    public async Task<JsonResult> AddItem([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/add-ap
    [HttpPost]
    [Route("add-ap")]
    public async Task<JsonResult> AddAP([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/pr/apt-item
    [HttpGet]
    [Route("apt-item")]
    public async Task<JsonResult> APTItem()
    {
        var result = await _repository.Op_05();
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/action-plan
    [HttpPost]
    [Route("action-plan")]
    public async Task<JsonResult> ActionPlan([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/ap
    [HttpPost]
    [Route("ap")]
    public async Task<JsonResult> AP([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/strategy
    [HttpPost]
    [Route("strategy")]
    public async Task<JsonResult> Strategy([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/pr/bp-status
    [HttpGet]
    [Route("bp-status")]
    public async Task<JsonResult> BPStatus()
    {
        var result = await _repository.Op_09();
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/add-item
    [HttpPost]
    [Route("item-check")]
    public async Task<JsonResult> ItemCheck([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/status-log
    [HttpPost]
    [Route("status-log")]
    public async Task<JsonResult> StatusLog([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/catalog
    [HttpPost]
    [Route("catalog")]
    public async Task<JsonResult> Catalog([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/pr/strategy
    [HttpPatch]
    [Route("strategy")]
    public async Task<JsonResult> UpdateStrategy([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/pr/strategy
    [HttpGet]
    [Route("strategy")]
    public async Task<JsonResult> GetStrategy()
    {
        var result = await _repository.Op_14();
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/attribute
    [HttpPost]
    [Route("attribute")]
    public async Task<JsonResult> QueryAttributes([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/pr/attribute
    [HttpDelete]
    [Route("attribute")]
    public async Task<JsonResult> RemoveAttributes([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/comment
    [HttpPost]
    [Route("comment")]
    public async Task<JsonResult> QueryComment([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/pr/comment
    [HttpDelete]
    [Route("comment")]
    public async Task<JsonResult> RemoveComment([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/pr/comment
    [HttpPut]
    [Route("comment")]
    public async Task<JsonResult> AddComment([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/pr/comment
    [HttpPatch]
    [Route("comment")]
    public async Task<JsonResult> UpdateComment([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/search-project
    [HttpPost]
    [Route("search-project")]
    public async Task<JsonResult> SearchProject([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/search-item
    [HttpPost]
    [Route("search-item")]
    public async Task<JsonResult> SearchItem([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/pr/search-ec
    [HttpPost]
    [Route("search-ec")]
    public async Task<JsonResult> SearchEC([FromBody] PRProcedure model)
    {
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/pr/attribute
    [HttpPut]
    [Route("attribute")]
    public async Task<JsonResult> AddAttributes([FromBody] PRProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }
}