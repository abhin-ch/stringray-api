using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.ER;
using StingrayNET.ApplicationCore.Models.ExcelService;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.ER)]
[ApiController]
public class ERController : ControllerBase
{
    private readonly IRepositoryXL<ERProcedure, ERResult> _repository;
    private readonly IIdentityService _identityService;
    private readonly IExcelService _excelService;

    public ERController(IRepositoryXL<ERProcedure, ERResult> repository, IIdentityService identityService, IExcelService excelService)
    {
        _repository = repository;
        _identityService = identityService;
        _excelService = excelService;
    }

    //POST api/er
    //Optional - Completed (Default false)
    [HttpPost]
    public async Task<JsonResult> GetER([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/status-log
    //Required - ERID 
    [HttpPost]
    [Route("status-log")]
    public async Task<JsonResult> GetStatusLog([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/deliverable
    //Required - ERID 
    [HttpPost]
    [Route("deliverable")]
    public async Task<JsonResult> GetDeliverables([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/deliverable
    //Required - UniqueIDNum
    [HttpDelete]
    [Route("deliverable")]
    public async Task<JsonResult> RemoveDeliverable([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/er/comment
    //Required - ERID 
    [HttpPost]
    [Route("comment")]
    public async Task<JsonResult> GetComments([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/risk
    //Required - ERID 
    [HttpPost]
    [Route("risk")]
    public async Task<JsonResult> GetRisks([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/wo
    //Required - ERID 
    [HttpPost]
    [Route("wo")]
    public async Task<JsonResult> GetWOs([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/prereq
    //Required - ERID 
    [HttpPost]
    [Route("prereq")]
    public async Task<JsonResult> GetPrereqs([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/change-log
    //Required - ERID 
    [HttpPost]
    [Route("change-log")]
    public async Task<JsonResult> GetChangeLog([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/p6
    //Required - ERID, ProjectID, ActivityID
    [HttpPut]
    [Route("p6")]
    public async Task<JsonResult> LinkP6Activity(ERProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/comment
    //Required - ERID 
    [HttpPut]
    [Route("comment")]
    public async Task<JsonResult> AddComment([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/risk
    //Required - ERID 
    [HttpPut]
    [Route("risk")]
    public async Task<JsonResult> AddRisk([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/comment
    //Required - ERID 
    [HttpDelete]
    [Route("comment")]
    public async Task<JsonResult> RemoveComment([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/risk
    //Required - ERID 
    [HttpDelete]
    [Route("risk")]
    public async Task<JsonResult> RemoveRisk([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPatch]
    public async Task<JsonResult> SaveER([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/er/assessment
    [HttpPatch]
    [Route("assessment")]
    public async Task<JsonResult> UpdateAssessment([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/er/admin/assessment
    [HttpGet]
    [Route("admin/assessment")]
    public async Task<JsonResult> GetAssessment()
    {
        var result = await _repository.Op_17();
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/admin/assessment
    [HttpPut]
    [Route("admin/assessment")]
    public async Task<JsonResult> AddAssessment([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/admin/assessment
    [HttpDelete]
    [Route("admin/assessment")]
    public async Task<JsonResult> DeleteAssessment([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/assessment
    [HttpPost]
    [Route("assessment")]

    public async Task<JsonResult> Assessment([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);

    }

    //GET api/er/admin/prerequisite
    [HttpGet]
    [Route("admin/prerequisite")]
    public async Task<JsonResult> GetPrerequisite()
    {
        var result = await _repository.Op_21();
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/admin/prerequisite
    [HttpPut]
    [Route("admin/prerequisite")]
    public async Task<JsonResult> AddPrerequisite([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/admin/prerequisite
    [HttpDelete]
    [Route("admin/prerequisite")]
    public async Task<JsonResult> DeletePrerequisite([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/prerequisite
    [HttpPost]
    [Route("prerequisite")]

    public async Task<JsonResult> Prerequisite([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);

    }

    //PUT api/er/deliverable
    [HttpPut]
    [Route("deliverable")]
    public async Task<JsonResult> AddDeliverable([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/deliverable
    [HttpGet]
    [Route("deliverable")]
    public async Task<JsonResult> GetDeliverable()
    {
        var result = await _repository.Op_26();
        return BaseResult.JsonResult(result);
    }

    //GET api/er/vendor
    [HttpGet]
    [Route("vendor")]
    public async Task<JsonResult> GetVendors()
    {
        var result = await _repository.Op_27();
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/resource
    [HttpPut]
    [Route("resource")]
    public async Task<JsonResult> AddResource([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }


    //DELETE api/er/resource
    [HttpDelete]
    [Route("resource")]
    public async Task<JsonResult> DeleteResource([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/resource
    [HttpPost]
    [Route("resource")]
    public async Task<JsonResult> Resource([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/admin/sm
    [HttpGet]
    [Route("admin/sm")]
    public async Task<JsonResult> GetSectionManagers()
    {
        var result = await _repository.Op_31();
        return BaseResult.JsonResult(result);
    }

    //PATCH api/er/status
    [HttpPatch]
    [Route("status")]
    public async Task<JsonResult> ChangeStatus([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/er/deliverable
    [HttpPatch]
    [Route("deliverable")]
    public async Task<JsonResult> EditDeliverable([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/toqlite
    [HttpPut]
    [Route("toqlite")]
    public async Task<JsonResult> CreateTOQLite([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/resource-type
    [HttpGet]
    [Route("resource-type")]
    public async Task<JsonResult> GetResourceTypes()
    {
        var result = await _repository.Op_35();
        return BaseResult.JsonResult(result);
    }

    //POST api/er/resource-log
    //Required - ERID 
    [HttpPost]
    [Route("resource-log")]
    public async Task<JsonResult> GetResourceLog([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_36(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/deliverable-log
    //Required - ERID 
    [HttpPost]
    [Route("deliverable-log")]
    public async Task<JsonResult> GetDeliverableLog([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_37(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/online-report
    [HttpPost]
    [Route("online-report")]
    public async Task<IActionResult> ExporttoExcelOnline(ExcelConvertRequest request)
    {
        var data = (await _repository.Op_38()).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }


    //GET api/er/section
    [HttpGet]
    [Route("section")]
    public async Task<JsonResult> GetSections()
    {
        ERProcedure model = new ERProcedure();
        model.SubOp = 1;
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/section
    [HttpPut]
    [Route("section")]
    public async Task<JsonResult> AddSections([FromBody] ERProcedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/er/section
    [HttpPatch]
    [Route("section")]
    public async Task<JsonResult> EditSections([FromBody] ERProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }


    //DELETE api/er/section
    [HttpDelete]
    [Route("section")]
    public async Task<JsonResult> RemoveSections([FromBody] ERProcedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/department
    [HttpGet]
    [Route("department")]
    public async Task<JsonResult> GetDepartments()
    {
        ERProcedure model = new ERProcedure();
        model.SubOp = 5;
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/admin/section
    [HttpGet]
    [Route("admin/section")]
    public async Task<JsonResult> GetAdminSections()
    {
        ERProcedure model = new ERProcedure();
        model.SubOp = 6;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/er/section/manager
    [HttpPost]
    [Route("section/manager")]
    public async Task<JsonResult> GetSectionManager([FromBody] ERProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/section/manager
    [HttpPut]
    [Route("section/manager")]
    public async Task<JsonResult> AddSectionManager([FromBody] ERProcedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/section/manager
    [HttpDelete]
    [Route("section/manager")]
    public async Task<JsonResult> RemoveSectionManger([FromBody] ERProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/er/comment
    [HttpPatch]
    [Route("comment")]
    public async Task<JsonResult> EditComments([FromBody] ERProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_41(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/project
    [HttpGet]
    [Route("project")]
    public async Task<JsonResult> GetProjects()
    {
        var result = await _repository.Op_42();
        return BaseResult.JsonResult(result);
    }

    //GET api/er/reason
    [HttpGet]
    [Route("reason")]
    public async Task<JsonResult> GetReason()
    {
        var model = new ERProcedure { };
        model.SubOp = 1;
        var result = await _repository.Op_43(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/er/admin/reason
    [HttpPut]
    [Route("admin/reason")]
    public async Task<JsonResult> AddAdminFocusArea([FromBody] ERProcedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_43(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/admin/reason
    [HttpDelete]
    [Route("admin/reason")]
    public async Task<JsonResult> DeleteAdminFocusArea([FromBody] ERProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_43(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/p6-report
    [HttpPost]
    [Route("p6-report")]
    public async Task<JsonResult> GetP6Report([FromBody] ERProcedure model)
    {
        var result = await _repository.Op_45(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/er/metric
    [HttpGet]
    [Route("metric")]
    public async Task<JsonResult> GetERMetricVariables()
    {
        ERProcedure model = new ERProcedure();
        model.SubOp = 1;
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/metric
    [HttpPost]
    [Route("metric")]
    public async Task<JsonResult> GetERMetrics([FromBody] ERProcedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/er/metric
    [HttpPatch]
    [Route("metric")]
    public async Task<JsonResult> EditERMetric([FromBody] ERProcedure model)
    {
        model.SubOp = 3;
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/er/metric
    [HttpDelete]
    [Route("metric")]
    public async Task<JsonResult> RemoveMetric([FromBody] ERProcedure model)
    {
        model.SubOp = 4;
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/er/export
    [HttpPost]
    [Route("export")]
    public async Task<IActionResult> ExportERs([FromBody] ExcelConvertRequest request, [FromQuery] byte subOp)
    {

        ERProcedure model = new ERProcedure();
        model.SubOp = subOp;
        var data = (await _repository.Op_47(model)).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }

}