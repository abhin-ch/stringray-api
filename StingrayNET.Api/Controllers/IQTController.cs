using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.IQT;
using System.Net;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class IQTController : ControllerBase
{
    private readonly IRepositoryM<IQTProcedure, IQTResult> _repository;

    public IQTController(IRepositoryM<IQTProcedure, IQTResult> repository)
    {
        _repository = repository;
    }

    //POST api/iqt/search-by-item
    [HttpPost]
    [Route("search-by-item")]
    public async Task<JsonResult> SearchByItem([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/search-by-location
    [HttpPost]
    [Route("search-by-location")]
    public async Task<JsonResult> SearchByLocation([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/doc
    [HttpPost]
    [Route("doc")]
    public async Task<JsonResult> Doc([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/ec
    [HttpPost]
    [Route("ec")]
    public async Task<JsonResult> EC([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/jp
    [HttpPost]
    [Route("jp")]
    public async Task<JsonResult> JP([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/pp-po
    [HttpPost]
    [Route("pp-po")]
    public async Task<JsonResult> PPPO([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/pr
    [HttpPost]
    [Route("pr")]
    public async Task<JsonResult> PR([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/rfq
    [HttpPost]
    [Route("rfq")]
    public async Task<JsonResult> RFQ([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/cr
    [HttpPost]
    [Route("cr")]
    public async Task<JsonResult> CR([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/bom
    [HttpPost]
    [Route("bom")]
    public async Task<JsonResult> BOM([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/pp-doc
    [HttpPost]
    [Route("pp-doc")]
    public async Task<JsonResult> PPDoc([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/iqt-mel
    [HttpPost]
    [Route("mel")]
    public async Task<JsonResult> IQTMEL([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/pp-aaa
    [HttpPost]
    [Route("pp-aaa")]
    public async Task<JsonResult> PPAAA([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/search-by-description
    [HttpPost]
    [Route("search-by-description")]
    public async Task<JsonResult> SearchByDescription([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/historical-wo
    [HttpPost]
    [Route("historical-wo")]
    public async Task<JsonResult> HistoricalWO([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/future-wo
    [HttpPost]
    [Route("future-wo")]
    public async Task<JsonResult> FutureWO([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/usage
    [HttpPost]
    [Route("usage")]
    public async Task<JsonResult> Usage([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/demand
    [HttpPost]
    [Route("demand")]
    public async Task<JsonResult> Demand([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/search-by-wo
    [HttpPost]
    [Route("search-by-wo")]
    public async Task<JsonResult> SearchByWO([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/passport-ole
    [HttpPost]
    [Route("passport-ole")]
    public async Task<JsonResult> PassportOLE([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/project
    [HttpPost]
    [Route("project")]
    [ProducesResponseType(typeof(Return<IQTResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Project([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/bom-children
    [HttpPost]
    [Route("bom-children")]
    public async Task<JsonResult> BOMChildren([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/manufacturer-info
    [HttpPost]
    [Route("manufacturer-info")]
    public async Task<JsonResult> ManufacturerInfo([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/comment
    [HttpPost]
    [Route("comment")]
    public async Task<JsonResult> Comment([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/csa
    [HttpPost]
    [Route("csa")]
    public async Task<JsonResult> CSA([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/csa
    [HttpPost]
    [Route("cognos")]
    public async Task<JsonResult> COGNOS([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/demand-forcast
    [HttpPost]
    [Route("demand-forcast")]
    public async Task<JsonResult> DemandForcast([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/pm
    [HttpPost]
    [Route("pm")]
    public async Task<JsonResult> PM([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/iqt/pm-jp
    [HttpPost]
    [Route("pm-jp")]
    public async Task<JsonResult> PMJP([FromBody] IQTProcedure model)
    {
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }
}