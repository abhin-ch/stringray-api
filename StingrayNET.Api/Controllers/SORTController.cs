using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.SORT;
using System.Net;
using Microsoft.AspNetCore.Cors;
using StingrayNET.ApplicationCore.Specifications.Request;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
[Authorize]
public class SORTController : ControllerBase
{
    private readonly IRepositoryS<SORTProcedure, SORTResult> _repository;

    public SORTController(IRepositoryS<SORTProcedure, SORTResult> repository)
    {
        _repository = repository;
    }

    //GET api/[controller]/mainlines
    [Route("mainlines")]
    [HttpGet]
    public async Task<JsonResult> GetMainList()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //GET api/[controller]/sublines
    [Route("sublines")]
    [HttpGet]
    public async Task<JsonResult> GetSubLines(string MainLinePK)
    {
        SORTProcedure model = new SORTProcedure();
        model.Value1 = MainLinePK;
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller/createline
    [Route("createline")]
    [HttpPost]
    public async Task<JsonResult> CreateNewLine([FromBody] RequestBody body)
    {
        //string PK_ID, int Type, string Category, int Probability, string? Estimated, string? Actualized, IEnumerable< TVPTag >? Tags
        var model = new SORTProcedure();
        model.Num1 = body.GetValue<int>("Type");
        model.Num2 = body.GetValue<int>("Probability");
        model.Value1 = body.GetValue<string>("PK_ID");
        model.Value2 = body.GetValue<string>("Category");
        model.Value3 = body.GetValue<string>("Estimated");
        model.Value4 = body.GetValue<string>("Actualized");
        //model.Tags = JsonSerializer.Deserialize<IEnumerable<TVPTable>>(body.GetValue<string>("Tags"));
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/[controller/updateline
    [Route("updateline")]
    [HttpPut]
    public async Task<JsonResult> UpdateLine([FromBody] RequestBody body)
    {
        var model = new SORTProcedure();
        model.Value1 = body.GetValue<string>("FK_ProjectID");
        model.Value2 = body.GetValue<string>("PK_ID");
        model.Value3 = body.GetValue<string>("UpdateCol");
        model.Value4 = body.GetValue<string>("UpdateVal");
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/[controller]/updatetags
    [Route("updatetags")]
    [HttpPut]
    public async Task<JsonResult> UpdateTags([FromBody] RequestBody body)
    {
        var model = new SORTProcedure();
        model.Value1 = body.GetValue<string>("FK_ProjectID");
        model.Value2 = body.GetValue<string>("PK_ID");
        //model.Tags = JsonSerializer.Deserialize<IEnumerable<TVPTable>>(body.GetValue<string>("Tags"));
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }
}
