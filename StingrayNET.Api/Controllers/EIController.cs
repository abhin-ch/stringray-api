using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.EI;
using StingrayNET.ApplicationCore.Models.ExcelService;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.EI)]
[ApiController]
public class EIController : ControllerBase
{
    private readonly IRepositoryL<EIProcedure, EIResult> _repository;
    private readonly IExcelService _excelService;
    public EIController(IRepositoryL<EIProcedure, EIResult> repository, IExcelService excelService)
    {
        _repository = repository;
        _excelService = excelService;
    }

    //GET api/ei
    [HttpGet]
    public async Task<JsonResult> GetInsights()
    {
        return BaseResult.JsonResult(await _repository.Op_01());
    }

    //POST api/ei
    [HttpPost]
    public async Task<JsonResult> CreateInsight([FromBody] EIProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_02(model));
    }

    //PATCH api/ei
    [HttpPatch]
    public async Task<JsonResult> UpdateInsight([FromBody] EIProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_03(model));
    }

    //DELETE api/ei
    [HttpDelete]
    public async Task<JsonResult> DeleteInsight([FromBody] EIProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_04(model));
    }

    //PATCH api/ei/status
    [HttpPatch]
    [Route("status")]
    public async Task<JsonResult> UpdateInsightStatus([FromBody] EIProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_05(model));
    }

    //GET api/ei/rating
    [HttpGet]
    [Route("rating")]
    public async Task<JsonResult> GetRatingOptions()
    {
        return BaseResult.JsonResult(await _repository.Op_06());
    }

    //GET api/ei/section
    [HttpGet]
    [Route("section")]
    public async Task<JsonResult> GetSectionOptions()
    {
        return BaseResult.JsonResult(await _repository.Op_07());
    }

    //GET api/ei/category
    [HttpGet]
    [Route("category")]
    public async Task<JsonResult> GetCategory()
    {
        var result = await _repository.Op_08();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/admin/category
    [HttpPut]
    [Route("admin/category")]
    public async Task<JsonResult> AddAdminCategory([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/admin/category
    [HttpDelete]
    [Route("admin/category")]
    public async Task<JsonResult> DeleteAdminCategory([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/category
    [HttpPost]
    [Route("category")]
    public async Task<JsonResult> RecordCategory([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/ei/category
    [HttpPatch]
    [Route("category")]
    public async Task<JsonResult> UpdateCategory([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/ei/organization
    [HttpGet]
    [Route("organization")]
    public async Task<JsonResult> GetOrganization()
    {
        var result = await _repository.Op_13();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/admin/organization
    [HttpPut]
    [Route("admin/organization")]
    public async Task<JsonResult> AddAdminOrganization([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/admin/organization
    [HttpDelete]
    [Route("admin/organization")]
    public async Task<JsonResult> DeleteAdminOrganization([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/organization
    [HttpPost]
    [Route("organization")]
    public async Task<JsonResult> RecordOrganization([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/ei/organization
    [HttpPatch]
    [Route("organization")]
    public async Task<JsonResult> UpdateOrganization([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/ei/deliverable
    [HttpGet]
    [Route("deliverable")]
    public async Task<JsonResult> GetDeliverable()
    {
        var result = await _repository.Op_18();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/admin/deliverable
    [HttpPut]
    [Route("admin/deliverable")]
    public async Task<JsonResult> AddAdminDeliverable([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/admin/deliverable
    [HttpDelete]
    [Route("admin/deliverable")]
    public async Task<JsonResult> DeleteAdminDeliverable([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/deliverable
    [HttpPost]
    [Route("deliverable")]
    public async Task<JsonResult> RecordDeliverable([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/ei/deliverable
    [HttpPatch]
    [Route("deliverable")]
    public async Task<JsonResult> UpdateDeliverable([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/ei/condition
    [HttpGet]
    [Route("condition")]
    public async Task<JsonResult> GetCondition()
    {
        var result = await _repository.Op_23();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/admin/condition
    [HttpPut]
    [Route("admin/condition")]
    public async Task<JsonResult> AddAdminCondition([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/admin/condition
    [HttpDelete]
    [Route("admin/condition")]
    public async Task<JsonResult> DeleteAdminCondition([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/condition
    [HttpPost]
    [Route("condition")]
    public async Task<JsonResult> RecordCondition([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/ei/condition
    [HttpPatch]
    [Route("condition")]
    public async Task<JsonResult> UpdateCondition([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/ei/project
    [HttpGet]
    [Route("project")]
    public async Task<JsonResult> GetProject()
    {
        var result = await _repository.Op_28();
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/project
    [HttpPost]
    [Route("project")]
    public async Task<JsonResult> RecordProject([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/ei/project
    [HttpPatch]
    [Route("project")]
    public async Task<JsonResult> UpdateProject([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/ei/review
    [HttpGet]
    [Route("review")]
    public async Task<JsonResult> GetReview()
    {
        var result = await _repository.Op_31();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/admin/review
    [HttpPut]
    [Route("admin/review")]
    public async Task<JsonResult> AddAdminReview([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/admin/review
    [HttpDelete]
    [Route("admin/review")]
    public async Task<JsonResult> DeleteAdminReview([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/review
    [HttpPost]
    [Route("review")]
    public async Task<JsonResult> RecordReview([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/ei/review
    [HttpPatch]
    [Route("review")]
    public async Task<JsonResult> UpdateReview([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_35(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/ei/outcome
    [HttpGet]
    [Route("outcome")]
    public async Task<JsonResult> GetOutcome()
    {
        var result = await _repository.Op_36();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/admin/outcome
    [HttpPut]
    [Route("admin/outcome")]
    public async Task<JsonResult> AddAdminOutcome([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_37(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/admin/outcome
    [HttpDelete]
    [Route("admin/outcome")]
    public async Task<JsonResult> DeleteAdminOutcome([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_38(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/ei/focus-area
    [HttpGet]
    [Route("focus-area")]
    public async Task<JsonResult> GetFocusArea()
    {
        var result = await _repository.Op_39();
        return BaseResult.JsonResult(result);
    }

    //PUT api/ei/focus-area
    [HttpPut]
    [Route("focus-area")]
    public async Task<JsonResult> AddAdminFocusArea([FromBody] EIProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ei/focus-area
    [HttpDelete]
    [Route("focus-area")]
    public async Task<JsonResult> DeleteAdminFocusArea([FromBody] EIProcedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/cr-dynamic
    [HttpPost]
    [Route("cr-dynamic")]
    public async Task<JsonResult> CRDynamic([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_41(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/ei/cr-dynamic-verify
    [HttpPost]
    [Route("cr-dynamic-verify")]
    public async Task<JsonResult> CRDynamicVerify([FromBody] EIProcedure model)
    {
        var result = await _repository.Op_42(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/ei/observed-group
    [HttpGet]
    [Route("observed-group")]
    public async Task<JsonResult> GetObservedGroup()
    {
        return BaseResult.JsonResult(await _repository.Op_43());
    }

    //POST api/ei/insights-report
    [HttpPost]
    [Route("insights-report")]
    public async Task<IActionResult> ExporttoExcelProcessHealth(ExcelConvertRequest request)
    {
        var data = (await _repository.Op_44()).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }


}