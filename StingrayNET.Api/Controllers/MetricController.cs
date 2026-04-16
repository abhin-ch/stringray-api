using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Metric;
using StingrayNET.ApplicationCore.Models.ExcelService;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class MetricController : ControllerBase
{
    private readonly IRepositoryXL<MetricProcedure, MetricResult> _repository;
    private readonly IExcelService _excelService;

    private readonly IMetricEmails _metricEmails;
    public MetricController(IRepositoryXL<MetricProcedure, MetricResult> repository, IExcelService excelService, IMetricEmails metricEmails)
    {
        _repository = repository;
        _excelService = excelService;
        _metricEmails = metricEmails;
    }


    //POST api/metric/measure
    [HttpPost]
    [Route("measure")]
    public async Task<JsonResult> AllMeasures([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/measure
    [HttpPut]
    [Route("measure")]
    public async Task<JsonResult> MainAdd([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/measure
    [HttpPatch]
    [Route("measure")]
    public async Task<JsonResult> EditMeaure([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //Delete api/metric/measure
    [HttpDelete]
    [Route("measure")]
    public async Task<OkObjectResult> MainRemove([FromBody] MetricProcedure model)
    {
        await _repository.Op_04(model);
        return new OkObjectResult(string.Format(@"measure was successfully removed"));
    }

    //GET api/metric/measure-category
    [HttpGet]
    [Route("measure-category")]
    public async Task<JsonResult> GetMeasureCategory()
    {
        var result = await _repository.Op_05();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/measure-category
    [HttpPut]
    [Route("measure-category")]
    public async Task<JsonResult> AddMeasureCategory([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/measure-category
    [HttpDelete]
    [Route("measure-category")]
    public async Task<JsonResult> DeleteMeasureCategory([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/frequency
    [HttpGet]
    [Route("frequency")]
    public async Task<JsonResult> GetFrequency()
    {
        var result = await _repository.Op_08();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/frequency
    [HttpPut]
    [Route("frequency")]
    public async Task<JsonResult> AddFrequency([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/frequency
    [HttpDelete]
    [Route("frequency")]
    public async Task<JsonResult> DeleteFrequency([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/measure-type
    [HttpGet]
    [Route("measure-type")]
    public async Task<JsonResult> GetMeasureType()
    {
        var result = await _repository.Op_11();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/measure-type
    [HttpPut]
    [Route("measure-type")]
    public async Task<JsonResult> AddMeasureType([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/measure-type
    [HttpDelete]
    [Route("measure-type")]
    public async Task<JsonResult> DeleteMeasureType([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/kpi-categorization
    [HttpGet]
    [Route("kpi-categorization")]
    public async Task<JsonResult> GetKPICategorization()
    {
        var result = await _repository.Op_14();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/kpi-categorization
    [HttpPut]
    [Route("kpi-categorization")]
    public async Task<JsonResult> AddKPICategorization([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/kpi-categorization
    [HttpDelete]
    [Route("kpi-categorization")]
    public async Task<JsonResult> DeleteKPICategorization([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/unit
    [HttpGet]
    [Route("unit")]
    public async Task<JsonResult> GetImot()
    {
        var result = await _repository.Op_17();
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/action-status
    [HttpGet]
    [Route("action-status")]
    public async Task<JsonResult> GetActionStatus()
    {
        var result = await _repository.Op_23();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/action-status
    [HttpPut]
    [Route("action-status")]
    public async Task<JsonResult> AddActionStatus([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/action-status
    [HttpDelete]
    [Route("action-status")]
    public async Task<JsonResult> DeleteActionStatus([FromBody] MetricProcedure model)
    {

        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/actions-review
    [HttpPost]
    [Route("actions-review")]
    public async Task<JsonResult> GetActionsReview([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/actions-review
    [HttpPut]
    [Route("actions-review")]
    public async Task<JsonResult> AddActionsReview([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //Delete api/metric/actions-review
    [HttpDelete]
    [Route("actions-review")]
    public async Task<JsonResult> DeleteActionsReview([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/measure-info
    [HttpGet]
    [Route("measure-info")]
    public async Task<JsonResult> GetMeasureInfo()
    {
        var result = await _repository.Op_29();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/measure-info
    [HttpPut]
    [Route("measure-info")]
    public async Task<JsonResult> AddAMeasureInfo([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/ownership-type
    [HttpGet]
    [Route("ownership-type")]
    public async Task<JsonResult> GetOwnershipType()
    {
        var result = await _repository.Op_31();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/ownership-type
    [HttpPut]
    [Route("ownership-type")]
    public async Task<JsonResult> AddOwnershipType([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/ownership-type
    [HttpDelete]
    [Route("ownership-type")]
    public async Task<JsonResult> DeleteOwnershipType([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/metric-owner
    [HttpPost]
    [Route("metric-owner")]
    public async Task<JsonResult> GetMetricOwner([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/metric-owner
    [HttpPut]
    [Route("metric-owner")]
    public async Task<JsonResult> AddMetricOwner([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_35(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/metric-owner
    [HttpDelete]
    [Route("metric-owner")]
    public async Task<JsonResult> DeleteMetricOwner([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_36(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/data-owner
    [HttpPost]
    [Route("data-owner")]
    public async Task<JsonResult> GetDataOwner([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_37(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/data-owner
    [HttpPut]
    [Route("data-owner")]
    public async Task<JsonResult> AddDataOwner([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_38(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/data-owner
    [HttpDelete]
    [Route("data-owner")]
    public async Task<JsonResult> DeleteDataOwner([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/monthly-variance
    [HttpPost]
    [Route("monthly-variance")]
    public async Task<JsonResult> GetMonthlyVariance([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/monthly-variance
    [HttpPatch]
    [Route("monthly-variance")]
    public async Task<JsonResult> EditMonthlyVariance([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_41(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/data-inputs-actuals
    [HttpPatch]
    [Route("data-inputs-actuals")]
    public async Task<JsonResult> UpdateDataInputsActuals([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_43(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/data-inputs-actuals
    [HttpPut]
    [Route("data-inputs-actuals")]
    public async Task<JsonResult> AddDataInputsActuals([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_44(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/data-inputs-actuals
    [HttpDelete]
    [Route("data-inputs-actuals")]
    public async Task<JsonResult> DeleteDataInputsActuals([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_45(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/actions-review
    [HttpPatch]
    [Route("actions-review")]
    public async Task<JsonResult> UpdateAction([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/criteria
    [HttpGet]
    [Route("criteria")]
    public async Task<JsonResult> GetCriteria()
    {
        var result = await _repository.Op_47();
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/criteria
    //Required - MetricID 
    [HttpPost]
    [Route("criteria")]
    public async Task<JsonResult> GeneralCriteria([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_48(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/criteria
    [HttpPatch]
    [Route("criteria")]
    public async Task<JsonResult> EditCriteria([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_49(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/criteria-operators
    [HttpGet]
    [Route("criteria-operators")]
    public async Task<JsonResult> GetCriteriaOperators()
    {
        var result = await _repository.Op_50();
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/data-inputs-actuals
    [HttpPost]
    [Route("data-inputs-actuals")]
    public async Task<JsonResult> GetDataInputsActuals([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_51(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/data-inputs-targets
    [HttpPost]
    [Route("data-inputs-targets")]
    public async Task<JsonResult> GetDataInputsTargets([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_52(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/data-inputs-targets
    [HttpPatch]
    [Route("data-inputs-targets")]
    public async Task<JsonResult> UpdateDataInputsTargets([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_53(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/data-inputs-targets
    [HttpDelete]
    [Route("data-inputs-targets")]
    public async Task<JsonResult> DeleteDataInputsTargets([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_54(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/data-inputs-targets
    [HttpPut]
    [Route("data-inputs-targets")]
    public async Task<JsonResult> AddDataInputsTargets([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_55(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/grid-monthly-target
    [HttpPost]
    [Route("grid-monthly-target")]
    public async Task<JsonResult> GetGridMonthlyTarget([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_56(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/grid-monthly-actual
    [HttpPost]
    [Route("grid-monthly-actual")]
    public async Task<JsonResult> GetGridMonthlyActual([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_57(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/grid-monthly-variance
    [HttpPost]
    [Route("grid-monthly-variance")]
    public async Task<JsonResult> GetGridMonthlyVariance([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_58(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/grid-ytd-variance
    [HttpPost]
    [Route("grid-ytd-variance")]
    public async Task<JsonResult> GetGridYTDVariance([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_59(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/criteria-concat
    [HttpPost]
    [Route("criteria-concat")]
    public async Task<JsonResult> GetCriteriaConcat([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_60(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/department
    [HttpGet]
    [Route("department")]
    public async Task<JsonResult> GetDepartment()
    {
        var result = await _repository.Op_61();
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/section
    [HttpGet]
    [Route("section")]
    public async Task<JsonResult> GetSection()
    {
        var result = await _repository.Op_62();
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/export-measures
    [HttpPost]
    [Route("export-measures")]
    public async Task<IActionResult> ExporttoExcelProcessHealth(ExcelConvertRequest request)
    {
        var data = (await _repository.Op_63()).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }

    //Get api/metric/month-year
    //No params
    [HttpGet]
    [Route("month-year")]
    public async Task<JsonResult> GetMonthYear()
    {
        var result = await _repository.Op_64();
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/monthly-chart-targets
    [HttpPost]
    [Route("monthly-chart-targets")]
    public async Task<JsonResult> GetMonthlyChartTargets([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_65(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/monthly-chart-actuals
    [HttpPost]
    [Route("monthly-chart-actuals")]
    public async Task<JsonResult> GetMonthlyChartActuals([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_66(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/ytd-chart-targets
    [HttpPost]
    [Route("ytd-chart-targets")]
    public async Task<JsonResult> GetYTDChartTargets([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_67(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/ytd-chart-actuals
    [HttpPost]
    [Route("ytd-chart-actuals")]
    public async Task<JsonResult> GetYTDChartActuals([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_68(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/status
    [HttpPatch]
    [Route("status")]
    public async Task<JsonResult> ChangeStatus([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_69(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/oversight-area
    [HttpGet]
    [Route("oversight-area")]
    public async Task<JsonResult> GetOversightArea()
    {
        var result = await _repository.Op_70();
        return BaseResult.JsonResult(result);
    }

    //PUT api/metric/admin/oversight-area
    [HttpPut]
    [Route("admin/oversight-area")]
    public async Task<JsonResult> AddAdminOversightArea([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_71(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/metric/admin/oversight-area
    [HttpDelete]
    [Route("admin/oversight-area")]
    public async Task<JsonResult> DeleteAdminOversightArea([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_72(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/metric/oversight-area
    [HttpPost]
    [Route("oversight-area")]
    public async Task<JsonResult> RecordOversightArea([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_73(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/metric/oversight-area
    [HttpPatch]
    [Route("oversight-area")]
    public async Task<JsonResult> UpdateOversightArea([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_74(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/year
    [HttpGet]
    [Route("year")]
    public async Task<JsonResult> GetYear()
    {
        var result = await _repository.Op_75();
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/monthly-percent-target
    [HttpPatch]
    [Route("monthly-percent-target")]
    public async Task<JsonResult> UpdateMonthlyPercentTarget([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_76(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/ytd-percent-target
    [HttpPatch]
    [Route("ytd-percent-target")]
    public async Task<JsonResult> UpdateYTDPercentTarget([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_77(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/metric/red-recovery
    [HttpPatch]
    [Route("red-recovery")]
    public async Task<JsonResult> UpdateRedRecovery([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_78(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/metric/active-status
    [HttpGet]
    [Route("active-status")]
    public async Task<JsonResult> GetActiveStatusValues()
    {
        var result = await _repository.Op_79();
        return BaseResult.JsonResult(result);
    }


    //POST api/metric/email
    [HttpPost]
    [Route("email")]
    public void Email([FromBody] MetricProcedure model)
    {
        _metricEmails.SendEmail(model);
    }

    //POST api/metric/report
    [HttpPost]
    [Route("report")]
    public async Task<JsonResult> ReportData([FromBody] MetricProcedure model)
    {
        var result = await _repository.Op_81(model);
        return BaseResult.JsonResult(result);
    }

}