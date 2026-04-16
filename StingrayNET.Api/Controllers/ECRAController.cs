using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.ECRA;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.ECRA)]
[ApiController]
public class ECRAController : ControllerBase
{
    private readonly IRepositoryL<ECRAProcedure, ECRAResult> _repository;
    public ECRAController(IRepositoryL<ECRAProcedure, ECRAResult> repository)
    {
        _repository = repository;
    }

    //GET api/ecra
    [HttpGet]
    public async Task<JsonResult> GetEC()
    {
        return BaseResult.JsonResult(await _repository.Op_01());
    }

    //PUT api/ecra
    [HttpPut]
    public async Task<JsonResult> AddEC([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_02(model));
    }

    //PATCH api/ecra
    [HttpPatch]
    public async Task<JsonResult> UpdateEC([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_03(model));
    }

    //DELETE api/ecra
    [HttpDelete]
    public async Task<JsonResult> RemoveEC([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_04(model));
    }

    //POST api/ecra/ec/search
    [HttpPost]
    [Route("ec/search")]
    public async Task<JsonResult> SearchEC([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_05(model));
    }

    //POST api/ecra/ec/search-verify
    [HttpPost]
    [Route("ec/search-verify")]
    public async Task<JsonResult> SearchVerifyEC([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_06(model));
    }

    //GET api/ecra/discipline
    [HttpGet]
    [Route("discipline")]
    public async Task<JsonResult> GetDiscipline()
    {
        return BaseResult.JsonResult(await _repository.Op_07());
    }

    //POST api/ecra/ael
    [HttpPost]
    [Route("ael")]
    public async Task<JsonResult> GetECAEL([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_08(model));
    }

    //POST api/ecra/related-dcn
    [HttpPost]
    [Route("related-dcn")]
    public async Task<JsonResult> GetRelatedDCN([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_09(model));
    }

    //POST api/ecra/perception/comment
    [HttpPost]
    [Route("perception/comment")]
    public async Task<JsonResult> GetPerceptionComments([FromBody] ECRAProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/ecra/perception/comment
    [HttpPut]
    [Route("perception/comment")]
    public async Task<JsonResult> AddPerceptionComment([FromBody] ECRAProcedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ecra/perception/comment
    [HttpDelete]
    [Route("perception/comment")]
    public async Task<JsonResult> RemovePerceptionComment([FromBody] ECRAProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/ecra/perception/comment
    [HttpPatch]
    [Route("perception/comment")]
    public async Task<JsonResult> EditPerceptionComment([FromBody] ECRAProcedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/ecra/proficiency/comment
    [HttpPost]
    [Route("proficiency/comment")]
    public async Task<JsonResult> GetProficiencyComments([FromBody] ECRAProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/ecra/proficiency/comment
    [HttpPut]
    [Route("proficiency/comment")]
    public async Task<JsonResult> AddProficiencyComment([FromBody] ECRAProcedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ecra/proficiency/comment
    [HttpDelete]
    [Route("proficiency/comment")]
    public async Task<JsonResult> RemoveProficiencyComment([FromBody] ECRAProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/ecra/proficiency/comment
    [HttpPatch]
    [Route("proficiency/comment")]
    public async Task<JsonResult> EditProficiencyComment([FromBody] ECRAProcedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/ecra/impact
    [HttpPatch]
    [Route("impact")]
    public async Task<JsonResult> UpdateImpact([FromBody] ECRAProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_12(model));
    }


}