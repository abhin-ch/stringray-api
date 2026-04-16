using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.Application.Modules.PCC;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.Requests;
using StingrayNET.ApplicationCore.Requests.PCC;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
public class BudgetingController : BaseApiController
{
    private readonly IRepositoryXL<PCCProcedure, PCCResult> _repository;
    private readonly IPCCService _pcc;

    public BudgetingController(IRepositoryXL<PCCProcedure, PCCResult> repository,
    IIdentityService identityService, IPCCService pcc) : base(identityService)
    {
        _repository = repository;
        _pcc = pcc;
    }

    //POST api/budgeting
    //MyRecord and Value1 (viewType) are optional
    [HttpPost]
    public async Task<JsonResult> GetBudgeting([FromBody] PCCGetPCCMainRequest request)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        request.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()!;
        var result = await _pcc.GetPCCMain(request);
        //var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/header-costs
    [HttpPost]
    [Route("sdq/header-costs")]
    //Requires SDQID
    public async Task<JsonResult> GetHeaderCosts([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_64(model));
    }

    //POST api/budgeting/sdq/active
    // [HttpPost]
    // [Route("sdq/active")]
    // public async Task<JsonResult> DoesSDQExist([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 1;
    //     var result = await _repository.Op_05(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PUT api/budgeting/sdq
    [HttpPut]
    [Route("sdq")]
    public async Task<JsonResult> CreateSDQ([FromBody] PCCProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 2;
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/pbrf
    [HttpPost]
    [Route("pbrf")]
    public async Task<JsonResult> CreatePBRF([FromBody] PCCProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _pcc.InitPBRF(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/sdq/phase
    [HttpGet]
    [Route("sdq/phase")]
    public async Task<JsonResult> GetPhase()
    {
        var result = await _repository.Op_22();
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/problem-definition
    [HttpPatch]
    [Route("sdq/problem-definition/statement")]
    public async Task<JsonResult> UpdateProblemDefinitionStatement([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 1;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/problem-definition
    [HttpPatch]
    [Route("sdq/problem-definition/information")]
    public async Task<JsonResult> UpdateProblemDefinitionInfo([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 2;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/scope-definition/definition
    [HttpPatch]
    [Route("sdq/scope-definition/definition")]
    public async Task<JsonResult> UpdateScopeDefinition([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 3;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/scope-definition/definition
    [HttpPatch]
    [Route("sdq/scope-definition/definition-long")]
    public async Task<JsonResult> UpdateScopeDefinitionLong([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 4;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/assumptions/assumptions
    [HttpPatch]
    [Route("sdq/assumptions/assumptions")]
    public async Task<JsonResult> UpdateAssumptions([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 5;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/assumptions/assumptions
    [HttpPatch]
    [Route("sdq/assumptions/assumptions-long")]
    public async Task<JsonResult> UpdateAssumptionsLong([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 6;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/risk/summary
    [HttpPatch]
    [Route("sdq/risk/summary")]
    public async Task<JsonResult> UpdateRiskSummary([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 7;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/risk/detail
    [HttpPatch]
    [Route("sdq/risk/detail")]
    public async Task<JsonResult> UpdateRiskDetail([FromBody] PCCProcedure model)
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 8;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/risk/variance-comment
    [HttpPatch]
    [Route("sdq/risk/variance-comment")]
    public async Task<JsonResult> UpdateRiskVarianceComment([FromBody] PCCProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.SubOp = 9;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/update-status/validation
    //Requires (SDQID or PBRID) and RecordType
    [HttpPost]
    [Route("update-status/validation")]
    public async Task<JsonResult> UpdateStatusValidation([FromBody] PCCUpdateStatusValidationRequest request)
    {
        request.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()!;
        var result = await _pcc.UpdateStatusValidation(request);
        if (result.Item1)
        {
            return BaseResult.JsonResult<HttpSuccess>();
        }
        return BaseResult.JsonResult<HttpSuccess>(result.Item2);
    }

    //POST api/budgeting/status-options
    //Requires (SDQID or PBRID) and RecordType
    [HttpPost]
    [Route("status-options")]
    public async Task<JsonResult> GetStatusOptions([FromBody] PCCStatusOptionsRequest request)
    {
        request.SetEmployeeID(HttpContext!.Items[@"EmployeeID"]?.ToString() ?? "");

        var options = await _pcc.GetStatusOptions(request);
        return BaseResult.JsonResult<HttpSuccess>(options);
        //return BaseResult.JsonResult(await _repository.Op_19(model));
    }

    //POST api/budgeting/status
    //Requires (SDQID or PBRID), RecordType, NextStatus, Comment (Optional)
    [HttpPost]
    [Route("status")]
    public async Task<JsonResult> GetPCCStatusOptions([FromBody] PCCStatusOptionsRequest request)
    {
        request.SetEmployeeID(HttpContext!.Items[@"EmployeeID"]?.ToString() ?? "");

        var options = await _pcc.GetStatusOptions(request);
        return BaseResult.JsonResult<HttpSuccess>(options);
    }


    //PATCH api/budgeting/status
    //Requires (SDQID or PBRID), RecordType, NextStatus, Comment (Optional)
    [HttpPatch]
    [Route("status")]
    public async Task<JsonResult> UpdateBudgetingStatus([FromBody] PCCUpdateStatusRequest request)
    {
        request.EmployeeID = HttpContext!.Items[@"EmployeeID"]?.ToString() ?? "";
        var resultMessage = await _pcc.UpdateStatus(request);
        return BaseResult.JsonResult<HttpSuccess>(resultMessage);
    }



    //GET api/budgeting/sdq/general/mpl/override
    // [HttpPatch]
    // [Route("sdq/general/mpl/override")]
    // public async Task<JsonResult> SaveSDQ_MPLOverride([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 3;
    //     var result = await _repository.Op_09(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/pbrf/general/mpl/override
    [HttpPatch]
    [Route("pbrf/general/mpl/override")]
    public async Task<JsonResult> SavePBRF_MPLOverride([FromBody] PCCProcedure model)
    {
        model.SubOp = 4;
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/general
    [HttpPatch]
    [Route("sdq/general")]
    public async Task<JsonResult> SaveSDQHeaderTab([FromBody] PCCProcedure model, [FromQuery] byte save)
    {
        if (save > 2) return BaseResult.JsonResult<HttpError>("Invalid save operation");
        model.SubOp = save;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/sdq/unit?id=23
    [HttpGet]
    [Route("sdq/unit")]
    public async Task<JsonResult> GetSDQUnit(int id)
    {
        var result = await _repository.Op_10(new PCCProcedure { Num1 = id });
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/status-log
    [HttpPost]
    [Route("status-log")]
    public async Task<JsonResult> GetStatusLog(PCCProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/status-action-log?id=34&type=sdq
    // [HttpGet]
    // [Route("status-action-log")]
    // public async Task<JsonResult> GetStatusActionLog(int id, string type)
    // {
    //     var result = await _repository.Op_03(new PCCProcedure { Num1 = id, Value2 = type });
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/sdq/p6
    // [HttpGet]
    // [Route("sdq/p6")]
    // public async Task<JsonResult> P6Tab(int sdquid, byte subOp, int? runSubID)
    // {
    //     var result = await _repository.Op_11(new PCCProcedure { Num1 = sdquid, SubOp = subOp, Num2 = runSubID });
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/sdq?sdquid=23
    [HttpGet]
    [Route("sdq")]
    public async Task<JsonResult> GetSDQ(int sdquid)
    {
        var result = await _repository.Op_08(new PCCProcedure { Num1 = sdquid, SubOp = 1 });
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/pbrf?uid=23
    [HttpGet]
    [Route("pbrf")]
    public async Task<JsonResult> GetPBRF(int uid)
    {
        var result = await _pcc.ValidatePBRFHeader(uid);
        if (result.Item1)
        {
            return BaseResult.JsonResult<HttpSuccess>();

        }
        return BaseResult.JsonResult<HttpSuccess>(result.Item2);
    }

    //POST api/budgeting/sdq/p6/local-mock
    [HttpPost]
    [Route("sdq/long-fields")]
    //Requires SDQID
    public async Task<JsonResult> GetSDQLongText([FromBody] PCCProcedure model)
    {
        model.RecordType = "SDQ";
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        return BaseResult.JsonResult(await _repository.Op_76(model));
    }

    [HttpPost]
    [Route("pbrf/long-fields")]
    //Requires SDQID
    public async Task<JsonResult> GetPBRFLongText([FromBody] PCCProcedure model)
    {
        model.RecordType = "PBRF";
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        return BaseResult.JsonResult(await _repository.Op_76(model));
    }

    //POST api/budgeting/sdq/p6/local-mock
    [HttpPost]
    [Route("sdq/p6/local-mock")]
    //Requires SDQID
    public async Task<JsonResult> CreateScheduleP6([FromBody] PCCProcedure model)
    {
        model.SubOp = 26;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        return BaseResult.JsonResult(await _pcc.P6Run(model));
    }

    //POST api/budgeting/sdq/p6
    [HttpPost]
    [Route("sdq/p6")]
    //Requires SDQID
    public async Task<JsonResult> GetP6Schedules([FromBody] PCCProcedure model)
    {
        model.SubOp = 1;
        return BaseResult.JsonResult(await _pcc.P6Run(model));
    }

    //PUT api/budgeting/sdq/p6/run
    [HttpPut]
    [Route("sdq/p6/run")]
    //Requires SDQID
    public async Task<JsonResult> GetP6RunID([FromBody] PCCProcedure model)
    {
        model.SubOp = 3;
        return BaseResult.JsonResult(await _pcc.P6Run(model));
    }

    //PUT api/budgeting/sdq/p6
    [HttpPut]
    [Route("sdq/p6")]
    //Requires P6RunID, SDQID, and ProjectID
    public async Task<JsonResult> ImportP6Schedule([FromBody] PCCProcedure model)
    {
        model.SubOp = 4;
        return BaseResult.JsonResult(await _pcc.P6Run(model));
    }

    //POST api/budgeting/sdq/p6/poll
    [HttpPost]
    [Route("sdq/p6/poll")]
    //Requires PipelineID, P6RunID, SDQID, and ProjectID
    public async Task<JsonResult> P6PipelinePoll([FromBody] PCCProcedure model)
    {
        model.SubOp = 25;
        return BaseResult.JsonResult(await _pcc.P6Run(model));
    }

    //PUT api/budgeting/sdq/p6/link
    [HttpPut]
    [Route("sdq/p6/link")]
    //Requires SDQID and P6RunID
    public async Task<JsonResult> LinkP6Schedule([FromBody] PCCProcedure model)
    {
        model.SubOp = 2;
        return BaseResult.JsonResult(await _pcc.P6Run(model));
    }

    //POST api/budgeting/sdq/p6/project
    [HttpPost]
    [Route("sdq/p6/project")]
    //Requires SDQID
    public async Task<JsonResult> GetProjectView([FromBody] PCCProcedure model)
    {
        model.SubOp = 6;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/deliverable
    [HttpPost]
    [Route("sdq/p6/deliverable")]
    //Requires SDQID
    public async Task<JsonResult> GetDeliverableView([FromBody] PCCProcedure model)
    {
        model.SubOp = 7;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //PATCH api/budgeting/sdq/p6/deliverable
    [HttpPatch]
    [Route("sdq/p6/deliverable")]
    //Requires SDQID, ActivityID, and RevisedCommitmentDate
    public async Task<JsonResult> EditDeliverable([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_55(model));
    }

    //POST api/budgeting/sdq/p6/cii-deliverable
    [HttpPost]
    [Route("sdq/p6/cii-deliverable")]
    //Requires SDQID
    public async Task<JsonResult> GetCIIDeliverableView([FromBody] PCCProcedure model)
    {
        model.SubOp = 8;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cii-org
    [HttpPost]
    [Route("sdq/p6/cii-org")]
    //Requires SDQID
    public async Task<JsonResult> GetCIIOrgView([FromBody] PCCProcedure model)
    {
        model.SubOp = 9;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cii-sds
    [HttpPost]
    [Route("sdq/p6/cii-sds")]
    //Requires SDQID
    public async Task<JsonResult> GetCIISDSView([FromBody] PCCProcedure model)
    {
        model.SubOp = 10;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cii-phase
    [HttpPost]
    [Route("sdq/p6/cii-phase")]
    //Requires SDQID
    public async Task<JsonResult> GetCIIPhaseView([FromBody] PCCProcedure model)
    {
        model.SubOp = 11;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cii-phase-summa
    [HttpPost]
    [Route("sdq/p6/cii-phase-summary")]
    //Requires SDQID
    public async Task<JsonResult> GetCIIPhaseSummaryView([FromBody] PCCProcedure model)
    {
        model.SubOp = 24;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cv-wbs
    [HttpPost]
    [Route("sdq/p6/cv-wbs")]
    //Requires SDQID
    public async Task<JsonResult> GetCVWBSView([FromBody] PCCProcedure model)
    {
        model.SubOp = 12;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cv-phase
    [HttpPost]
    [Route("sdq/p6/cv-phase")]
    //Requires SDQID
    public async Task<JsonResult> GetCVPhaseView([FromBody] PCCProcedure model)
    {
        model.SubOp = 13;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cv-sds
    [HttpPost]
    [Route("sdq/p6/cv-sds")]
    //Requires SDQID
    public async Task<JsonResult> GetCVSDSView([FromBody] PCCProcedure model)
    {
        model.SubOp = 14;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cv-phase-view
    [HttpPost]
    [Route("sdq/p6/cv-phase-view")]
    //Requires SDQID
    public async Task<JsonResult> GetCVPhaseSummaryView([FromBody] PCCProcedure model)
    {
        model.SubOp = 15;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/cv-phase-summary
    [HttpPost]
    [Route("sdq/p6/cv-phase-summary")]
    //Requires SDQID
    public async Task<JsonResult> GetCVPhaseSummary([FromBody] PCCProcedure model)
    {
        model.SubOp = 16;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/sds-summary-cii
    [HttpPost]
    [Route("sdq/p6/sds-summary-cii")]
    //Requires SDQID
    public async Task<JsonResult> GetSDSCIISummaryView([FromBody] PCCProcedure model)
    {
        model.SubOp = 17;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/sds-summary-cv
    [HttpPost]
    [Route("sdq/p6/sds-summary-cv")]
    //Requires SDQID
    public async Task<JsonResult> GetSDSCVSummaryView([FromBody] PCCProcedure model)
    {
        model.SubOp = 18;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/sds-summary-lamp
    [HttpPost]
    [Route("sdq/p6/sds-summary-lamp")]
    //Requires SDQID
    public async Task<JsonResult> GetSDSLampSummaryView([FromBody] PCCProcedure model)
    {
        model.SubOp = 19;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/forecast
    [HttpPost]
    [Route("sdq/p6/forecast")]
    //Requires SDQID
    public async Task<JsonResult> GetP6ForecastView([FromBody] PCCProcedure model)
    {
        model.SubOp = 20;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/forecast-cii
    [HttpPost]
    [Route("sdq/p6/forecast-cii")]
    //Requires SDQID
    public async Task<JsonResult> GetP6ForecastCIIView([FromBody] PCCProcedure model)
    {
        model.SubOp = 21;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/forecast-cpv
    [HttpPost]
    [Route("sdq/p6/forecast-cpv")]
    //Requires SDQID
    public async Task<JsonResult> GetP6ForecastCPVView([FromBody] PCCProcedure model)
    {
        model.SubOp = 22;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/discipline
    [HttpPost]
    [Route("sdq/p6/discipline")]
    //Requires SDQID
    public async Task<JsonResult> GetP6DisciplineView([FromBody] PCCProcedure model)
    {
        model.SubOp = 23;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/pmpc
    [HttpPost]
    [Route("sdq/p6/pmpc")]
    //Requires SDQID
    public async Task<JsonResult> GetPMPC([FromBody] PCCProcedure model)
    {
        model.SubOp = 27;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/error
    [HttpPost]
    [Route("sdq/p6/error")]
    //Requires P6RunID
    public async Task<JsonResult> GetP6ValidationErrors([FromBody] PCCProcedure model)
    {
        model.SubOp = 28;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/p6/financial-summary
    [HttpPost]
    [Route("sdq/financial-summary")]
    //Requires SDQID
    public async Task<JsonResult> GetFinancialSummary([FromBody] PCCProcedure model)
    {
        model.SubOp = 29;
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //POST api/budgeting/sdq/amot
    [HttpPost]
    [Route("sdq/amot")]
    public async Task<JsonResult> AddAMOT([FromBody] PCCProcedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/budgeting/sdq/amot
    [HttpDelete]
    [Route("sdq/amot")]
    public async Task<JsonResult> DeleteAMOT([FromBody] PCCProcedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/sdq/amot
    [HttpGet]
    [Route("sdq/amot")]
    public async Task<JsonResult> GetAMOT(int sdquid)
    {
        var result = await _repository.Op_27(new PCCProcedure { Num1 = sdquid, SubOp = 3 });
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/sdq/scope-trend-options
    [HttpGet]
    [Route("sdq/scope-trend-options")]
    public async Task<JsonResult> GetScopeTrendOptions()
    {
        return BaseResult.JsonResult(await _repository.Op_61(new PCCProcedure()));
    }

    //GET api/budgeting/sdq/related-toq
    [HttpGet]
    [Route("sdq/related-toq")]
    public async Task<JsonResult> RelatedTOQ(int SDQID)
    {
        var model = new PCCProcedure { SDQID = SDQID, SubOp = 4 };
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/related-toq/approved-amount
    // [HttpPatch]
    // [Route("sdq/related-toq/approved-amount")]
    // public async Task<JsonResult> UpdateApprovedAmount([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 7;
    //     var result = await _repository.Op_13(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/sdq/related-toq/funding
    // [HttpGet]
    // [Route("sdq/related-toq/funding")]
    // public async Task<JsonResult> GetTOQFundingCheck(int sdquid)
    // {
    //     var result = await _repository.Op_13(new PCCProcedure { SubOp = 5, Num1 = sdquid });
    //     return BaseResult.JsonResult(result);
    // }

    //PATCH api/budgeting/sdq/related-toq/funding
    // [HttpPatch]
    // [Route("sdq/related-toq/funding")]
    // public async Task<JsonResult> UpdateTOQFundingCheck([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 6;
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_13(model);
    //     return BaseResult.JsonResult(result);
    // }

    //POST api/budgeting/sdq/related-toq
    [HttpPost]
    [Route("sdq/related-toq")]
    public async Task<JsonResult> AddRelatedTOQ([FromBody] PCCProcedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/budgeting/sdq/related-toq
    [HttpDelete]
    [Route("sdq/related-toq")]
    public async Task<JsonResult> RemoveRelatedTOQ([FromBody] PCCProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/related-toq/search
    [HttpPost]
    [Route("sdq/related-toq/search")]
    public async Task<JsonResult> SearchRelatedTOQ([FromBody] PCCProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/sdq/related-toq/search
    [HttpGet]
    [Route("sdq/related-toq/search")]
    public async Task<JsonResult> GetTOQTypeStatusVendor()
    {
        var result = await _repository.Op_14();
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/projects
    [HttpGet]
    [Route("projects")]
    public async Task<JsonResult> GetProjects()
    {
        var result = await _repository.Op_06();
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/sm
    [HttpPost]
    [Route("sdq/sm")]
    public async Task<JsonResult> GetSMApprovals(PCCProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/sm/status-log
    // [HttpPost]
    // [Route("sdq/sm/status-log")]
    // public async Task<JsonResult> GetSMApprovalsLog(PCCProcedure model)
    // {
    //     var result = await _repository.Op_16(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PATCH api/budgeting/sdq/sm/approval
    // [HttpPatch]
    // [Route("sdq/sm/approval")]
    // public async Task<JsonResult> UpdateSMApproval([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 3;
    //     var result = await _repository.Op_16(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/sdq/sm/approval
    // [HttpGet]
    // [Route("sdq/sm/approval")]
    // public async Task<JsonResult> GetSMApprovalStatus(int sdquid, string smid)
    // {
    //     var result = await _repository.Op_16(new PCCProcedure { Num1 = sdquid, Value1 = smid, SubOp = 4 });
    //     return BaseResult.JsonResult(result);
    // }

    //SUPERSEDED by POST api/budgeting/sdq/customer-approval
    //GET api/budgeting/sdq/customer-approval
    // [HttpGet]
    // [Route("sdq/customer-approval")]
    // public async Task<JsonResult> GetCustomerApproval(int sdquid, string customerID)
    // {
    //     var result = await _repository.Op_21(new PCCProcedure { Num1 = sdquid, SubOp = 1, Value1 = customerID });
    //     return BaseResult.JsonResult(result);
    // }

    //POST api/budgeting/sdq/customer-approval
    [HttpPost]
    [Route("sdq/customer-approval")]
    //Requires SDQID
    public async Task<JsonResult> GetCustomerApproval([FromBody] PCCProcedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/customer-approval
    [HttpPatch]
    [Route("sdq/customer-approval")]
    //Requires CustomerApprovalID, CurrentApproval, and Comment
    public async Task<JsonResult> EditCustomerApproval([FromBody] PCCProcedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/validate
    // [HttpPost]
    // [Route("sdq/validate")]
    // public async Task<JsonResult> SDQChangeStatusValidation([FromBody] PCCProcedure model)
    // {

    //     var result = await _repository.Op_15(model);
    //     return BaseResult.JsonResult(result);
    // }

    //POST api/budgeting/sdq/validate/header
    // [HttpPost]
    // [Route("sdq/validate/header")]
    // public async Task<JsonResult> ValidateSDQHeader([FromBody] SDQModel model)
    // {
    //     var validateResult = new SDQValidationModel(model);
    //     return BaseResult.JsonResult<HttpSuccess>(validateResult);
    // }

    //GET api/budgeting/pbrf-header-options
    [HttpGet]
    [Route("pbrf-header-options")]
    public async Task<JsonResult> GetPBRFHeader()
    {
        var result = await _repository.Op_04(new PCCProcedure { SubOp = 1 });
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/change-type-options
    // [HttpPost]
    // [Route("sdq/change-type-options")]
    // public async Task<JsonResult> GetSDQChangeTypeOptions(PCCProcedure model)
    // {
    //     model.SubOp = 2;
    //     var result = await _repository.Op_04(model);
    //     return BaseResult.JsonResult(result);
    // }

    //POST api/budgeting/pbrf-header
    [HttpPost]
    [Route("pbrf-header")]
    public async Task<JsonResult> SavePBRFHeader([FromBody] PCCProcedure model)
    {
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/pbrf/cost-estimate
    [HttpGet]
    [Route("pbrf/cost-estimate")]
    public async Task<JsonResult> GetPBRFCostEstimate(int id)
    {
        var result = await _repository.Op_28(new PCCProcedure { Num1 = id, SubOp = 3 });
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/admin-tool/sdq/inactive-options
    // [HttpGet]
    // [Route("admin-tool/sdq/inactive-options")]
    // public async Task<JsonResult> GetSDQInactiveOptions()
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.SubOp = 1;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PATCH api/budgeting/admin-tool/remove-option
    // [HttpPatch]
    // [Route("admin-tool/remove-option")]
    // public async Task<JsonResult> RemoveOption([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 2;
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PATCH api/budgeting/admin-tool/activate-option
    // [HttpPatch]
    // [Route("admin-tool/activate-option")]
    // public async Task<JsonResult> ActivateOption([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 3;
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PATCH api/budgeting/admin-tool/edit-option
    // [HttpPatch]
    // [Route("admin-tool/edit-option")]
    // public async Task<JsonResult> EditOption([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 4;
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PUT api/budgeting/admin-tool/add-option
    // [HttpPut]
    // [Route("admin-tool/add-option")]
    // public async Task<JsonResult> AddOption([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 5;
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/admin-tool/pbrf/inactive-options
    // [HttpGet]
    // [Route("admin-tool/pbrf/inactive-options")]
    // public async Task<JsonResult> GetPBRFInactiveOptions()
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.SubOp = 6;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/admin-tool/changelog
    // [HttpGet]
    // [Route("admin-tool/changelog")]
    // public async Task<JsonResult> AdminToolChangeLog()
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.SubOp = 7;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //Patch api/budgeting/admin-tool/reorder
    // [HttpPatch]
    // [Route("admin-tool/reorder")]
    // public async Task<JsonResult> AdminToolReorder([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 8;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/admin-tool/sdq/nestoptions
    // [HttpGet]
    // [Route("admin-tool/sdq/nestoptions")]
    // public async Task<JsonResult> SDQNestOptions()
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.SubOp = 9;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/admin-tool/sdq/nestdetails
    // [HttpGet]
    // [Route("admin-tool/sdq/nestdetails")]
    // public async Task<JsonResult> SDQNestDetails(int? SubOp, string? Value1)
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.Value1 = Value1;
    //     model.SubOp = 10;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //PUT api/budgeting/admin-tool/add-nestedoption
    // [HttpPut]
    // [Route("admin-tool/add-nestedoption")]
    // public async Task<JsonResult> AddNestedOption([FromBody] PCCProcedure model)
    // {
    //     model.SubOp = 11;
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/admin-tool/dvn/nestoptions
    // [HttpGet]
    // [Route("admin-tool/dvn/nestoptions")]
    // public async Task<JsonResult> DVNNestOptions()
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.SubOp = 12;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/admin-tool/dvn/nestdetails
    // [HttpGet]
    // [Route("admin-tool/dvn/nestdetails")]
    // public async Task<JsonResult> DVNNestDetails(int? SubOp, string? Value1)
    // {
    //     PCCProcedure model = new PCCProcedure();
    //     model.Value1 = Value1;
    //     model.SubOp = 13;
    //     var result = await _repository.Op_17(model);
    //     return BaseResult.JsonResult(result);
    // }

    //GET api/budgeting/sdq/minor-changes
    [HttpGet]
    [Route("sdq/minor-changes")]
    public async Task<JsonResult> GetMinorChangesType()
    {
        PCCProcedure model = new PCCProcedure();
        model.SubOp = 1;
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/minor-changes
    [HttpPost]
    [Route("sdq/minor-changes")]
    public async Task<JsonResult> GetSDQMinorChanges([FromBody] PCCProcedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/budgeting/sdq/minor-changes
    [HttpPut]
    [Route("sdq/minor-changes")]
    public async Task<JsonResult> AddMinorChange([FromBody] PCCProcedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/budgeting/sdq/minor-changes
    [HttpDelete]
    [Route("sdq/minor-changes")]
    public async Task<JsonResult> RemoveMinorChange([FromBody] PCCProcedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/minor-changes
    [HttpPatch]
    [Route("sdq/minor-changes")]
    public async Task<JsonResult> EditMinorChange([FromBody] PCCProcedure model)
    {
        model.SubOp = 5;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/sdq/calc
    // [HttpGet]
    // [Route("sdq/calc")]
    // public async Task<JsonResult> GETSDQValues(int sdquid)
    // {
    //     var result = await _repository.Op_18(new PCCProcedure { Num1 = sdquid });
    //     return BaseResult.JsonResult(result);
    // }

    /*
            //GET api/budgeting/sdq/field-change-log
            [HttpGet]
            [Route("sdq/field-change-log")]
            [AppSecurity("GetFieldChangeLog", AppSecurityTypeEnum.Data, "View list of field change log records", "Field Change Log")]
            public async Task<JsonResult> GetFieldChangeLog()
            {
                var result = await _repository.Op_19(new PCCProcedure { SubOp = 1 });
                return BaseResult.JsonResult(result);
            }

            //POST api/budgeting/sdq/field-change-log
            [HttpPost]
            [Route("sdq/field-change-log")]
            [AppSecurity("SaveFieldChangeLog", AppSecurityTypeEnum.Data, "Save record to field change log", "Field Change Log")]
            public async Task<JsonResult> SaveFieldChangeLog([FromBody] PCCProcedure model)
            {
                model.SubOp = 2;
                model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
                var result = await _repository.Op_19(model);
                return BaseResult.JsonResult(result);
            }
        */
    //POST api/budgeting/email-notification
    // [Route("email-notification")]
    // [HttpPost]
    // public async Task<JsonResult> GetEmail([FromBody] PCCProcedure model)
    // {

    //     var result = await _repository.Op_31(model);
    //     return BaseResult.JsonResult(result);
    // }

    #region DVN

    [HttpPost]
    [Route(@"dvn")]
    //DVNID is required
    public async Task<JsonResult> GetDVNs(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_32(model));
    }

    [HttpPost]
    [Route(@"dvn/activity")]
    //Requires DVNID
    public async Task<JsonResult> GetDVNDetails(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_33(model));
    }

    [HttpPut]
    [Route(@"dvn")]
    //Requires SDQID
    public async Task<JsonResult> AddDVN(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_38(model));
    }

    // [HttpPut]
    // [Route(@"dvn/activity")]
    //Requires DVNID and DVNActivities
    // public async Task<JsonResult> AddDVNActivity(PCCProcedure model)
    // {
    //     return BaseResult.JsonResult(await _repository.Op_34(model));
    // }

    [HttpPatch]
    [Route(@"dvn/activity")]
    //Requires DVNID and ActivityID and (ReasonCodeID, ActivityNoChange, DVNActivityRevisedCommitmentDate (All optional))
    public async Task<JsonResult> EditDVNActivity(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_35(model));
    }

    [HttpPatch]
    [Route(@"dvn/activity/scr")]
    //Requires DVNID and ActivityID and SCR
    public async Task<JsonResult> EditDVNActivitySCR(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_58(model));
    }

    // [HttpDelete]
    // [Route(@"dvn/activity")]
    //Requires DVNID and ActivityID
    // public async Task<JsonResult> RemoveDVNActivity(PCCProcedure model)
    // {
    //     return BaseResult.JsonResult(await _repository.Op_36(model));
    // }

    [HttpPatch]
    [Route(@"dvn/route")]
    //Requires DVNID and NextStatus; Comment is optional
    public async Task<JsonResult> RouteDVN(PCCProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        await _pcc.UpdateStatusDVN(model);
        return BaseResult.JsonResult<HttpSuccess>();
    }

    [HttpPost]
    [Route(@"dvn/next-status")]
    //Requires DVNID or ProjectID/DVNNumber
    public async Task<JsonResult> GetNextStatus(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_40(model));
    }

    [HttpPost]
    [Route(@"dvn/scr")]
    //Requires SCR
    public async Task<JsonResult> GetSCR(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_41(model));
    }

    [HttpPost]
    [Route(@"dvn/scr-verify")]
    //Requires SCR
    public async Task<JsonResult> VerifySCR(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_42(model));
    }

    [HttpGet]
    [Route(@"dvn/reason-codes")]
    public async Task<JsonResult> GetReasonCodes()
    {
        return BaseResult.JsonResult(await _repository.Op_43());
    }

    [HttpPatch]
    [Route(@"dvn")]
    //Requires DVNID; DVNRationale is optional
    public async Task<JsonResult> EditDVN(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_37(model));
    }

    [HttpPost]
    [Route(@"dvn/status-log")]
    //Requires DVNID
    public async Task<JsonResult> GetDVNStatusLog(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_44(model));

    }

    // [HttpPost]
    // [Route(@"dvn/activity-search")]
    //Requires DVNID
    // public async Task<JsonResult> SearchActivityID(PCCProcedure model)
    // {
    //     return BaseResult.JsonResult(await _repository.Op_45(model));
    // }

    #endregion

    #region UI RSS

    [HttpPost]
    [Route("ui-access")]
    //Requires RecordType and (RecordUID or DVNID if RecordType = DVN))
    public async Task<JsonResult> GetUIAccessibility(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_49(model));
    }

    #endregion

    #region SDQ P6 Override

    [HttpPatch]
    [Route(@"sdq/p6/sdswp")]
    //Requires SDQID, WBSCode, CV, and SDSWPOverride
    public async Task<JsonResult> OverrideSDSWP(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_48(model));
    }

    #endregion

    #region PDF and Forecast Upload
    [AllowAnonymous]
    [HttpGet]
    [Route(@"sdq/p6/pdf-upload")]
    public async Task UploadP6PDF()
    {
        await _repository.Op_46();
    }

    [AllowAnonymous]
    [HttpGet]
    [Route(@"sdq/p6/forecast-upload")]
    public async Task UploadP6Forecast()
    {
        await _repository.Op_46();
    }

    [HttpPost]
    [Route(@"sdq/p6/forecast-process")]
    public async Task<JsonResult> PostProcessP6Forecast(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_47(model));
    }

    [HttpPost]
    [Route(@"sdq/p6/forecast-process/poll")]
    public async Task<JsonResult> PostProcessP6ForecastPoll(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_50(model));
    }

    #endregion

    #region Checklist Endpoints

    [HttpPost]
    [Route(@"sdq/checklist")]
    //Requires SDQID and  ChecklistType
    public async Task<JsonResult> GetChecklist(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_51(model));
    }

    [HttpPatch]
    [Route(@"sdq/checklist")]
    //Requires InstanceQuestionID and one or more of the following: ChecklistSupportingData, Comment, QuestionResponse
    public async Task<JsonResult> EditChecklist(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_52(model));
    }

    #endregion

    #region Revised Commitments


    [HttpPost]
    [Route(@"sdq/revised-commitments")]
    //Requires SDQID 
    public async Task<JsonResult> GetRevisedCommitments(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_53(model));
    }

    [HttpPatch]
    [Route(@"sdq/revised-commitments")]
    //Requires SDQID, ActivityID, and RevisedCommitment
    public async Task<JsonResult> EditRevisedCommitment(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_54(model));
    }

    [HttpPost]
    [Route(@"sdq/revised-commitments/preview")]
    //Requires SDQID 
    public async Task<JsonResult> GetRevisedCommitmentPreview(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_57(model));
    }

    [HttpPost]
    [Route(@"sdq/report")]
    //Requires SDQID 
    public async Task<JsonResult> GetSDQSDQReport([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult<HttpSuccess>(await _pcc.GetSDQPDFReport(model.SDQID!.Value));
    }

    #endregion

    [AllowAnonymous]
    [HttpGet]
    [Route(@"sdq/legacy-file-upload")]
    public async Task UploadLegacyFile()
    {
        await _repository.Op_65();
    }

    //POST api/budgeting/sdq/eac-variance
    [HttpPost]
    [Route("sdq/eac-variance")]
    //Requires SDQID
    public async Task<JsonResult> GetEACVariance([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_56(model));

    }
    #region Funding Allocation Endpoints

    [HttpPost]
    [Route(@"sdq/fundingallocation")]
    //Requires SDQID
    public async Task<JsonResult> Getfundingallocation(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_62(model));
    }

    [HttpPost]
    [Route(@"sdq/fundingallocationcheck")]
    //Requires SDQUID, RespORg and Multiplevendor
    public async Task<JsonResult> Editfundingallocation(PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_63(model));
    }
    [HttpPost]
    [Route(@"sdq/fundingallocationtotalcheck")]
    //Requires SDQID
    public async Task<JsonResult> Getfundingallocationtotalcheck(PCCProcedure model)
    {
        return BaseResult.JsonResult(await this._repository.Op_69(model));
    }
    //GET api/budgeting/sectiondept
    [HttpGet]
    [Route("sectiondept")]
    public async Task<JsonResult> GetSectionDept()
    {
        return BaseResult.JsonResult(await _repository.Op_72());
    }

    #endregion

    #region SDQ PDF Graph Endpoints

    //POST api/budgeting/sdq/eac-trend
    [HttpPost]
    [Route("sdq/eac-trend")]
    //Requires SDQID
    public async Task<JsonResult> GetEACTrend([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_59(model));
    }

    //POST api/budgeting/sdq/eac-engineering
    [HttpPost]
    [Route("sdq/eac-engineering")]
    //Requires SDQID
    public async Task<JsonResult> GetEACEngineering([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_60(model));
    }

    //POST api/budgeting/sdq/pdf-signatures
    [HttpPost]
    [Route("sdq/pdf-signatures")]
    //Requires SDQID
    public async Task<JsonResult> GetPDFSignatures([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_66(model));
    }

    //POST api/budgeting/sdq/previous-eac
    [HttpPost]
    [Route("sdq/previous-eac")]
    //Requires SDQID
    public async Task<JsonResult> GetPreviousEAC([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_67(model));
    }

    //POST api/budgeting/sdq/approval-report
    [HttpPost]
    [Route("sdq/approval-report")]
    //Requires SDQID
    public async Task<JsonResult> GetSDQApprovalReport([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_68(model));
    }

    //POST api/budgeting/sdq/report/p6-schedule
    [HttpPost]
    [Route("sdq/report/p6-schedule")]
    //Requires SDQID
    public async Task<JsonResult> GetP6Schedule([FromBody] PCCProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_73(model));
    }
    #endregion

    //PATCH api/budgeting/sdq/digital-engineering-cost-savings
    [HttpPatch]
    [Route(@"sdq/digital-engineering-cost-savings")]
    public async Task<JsonResult> EditDigitalEngCostSavings(PCCProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_74(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/digital-engineering-cost-savings
    [HttpPost]
    [Route(@"sdq/digital-engineering-cost-savings")]
    public async Task<JsonResult> EditOverallDigitalEngCostSavings(PCCProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_75(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/budgeting/sdq/sds-code-version
    [HttpPatch]
    [Route("sdq/sds-code-version")]
    public async Task<JsonResult> UpdateSDSCodeVersionSDQ([FromBody] PCCProcedure model)
    {
        model.SubOp = 30;
        var result = await _pcc.P6Run(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/budgeting/sdq/sds-code-version
    [HttpPost]
    [Route("sdq/sds-code-version")]
    public async Task<JsonResult> GetSDSCodeVersionSDQ([FromBody] PCCProcedure model)
    {
        model.SubOp = 31;
        var result = await _pcc.P6Run(model);
        return BaseResult.JsonResult(result);
    }

    #region Options

    //GET api/budgeting/options/sdq/sds-code-version
    [HttpGet]
    [Route("options/sdq/sds-code-version")]
    public async Task<JsonResult> GetSDSCodeVersionOptions()
    {
        var result = await _pcc.GetDropdownOptions(6);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("options/sdq-verifiers")]
    public async Task<JsonResult> GetSDQVerifiers([FromBody] PCCProcedure model)
    {
        model.SubOp = 1;
        return BaseResult.JsonResult(await _repository.Op_90(model));
    }

    //GET api/budgeting/options/sdq/business-driver
    [HttpGet]
    [Route("options/sdq/business-driver")]
    public async Task<JsonResult> GetSDQMainOptions()
    {
        var result = await _pcc.GetDropdownOptions(2);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("options/sdq/eac-variance-comment")]
    public async Task<JsonResult> GetEACVarianceCommentOptions()
    {
        var result = await _pcc.GetDropdownOptions(5);
        return BaseResult.JsonResult(result);
    }

    //GET api/budgeting/options/sdq/complexity
    [HttpGet]
    [Route("options/sdq/complexity")]
    public async Task<JsonResult> GetSDQComplexity()
    {
        var result = await _repository.Op_90(new PCCProcedure { SubOp = 3 });
        return BaseResult.JsonResult(result);
    }

    //Post api/budgeting/options/status
    [HttpPost]
    [Route("options/status")]
    public async Task<JsonResult> GetAdminStatus([FromBody] PCCProcedure model)
    {
        model.SubOp = 4;
        return BaseResult.JsonResult(await _repository.Op_90(model));
    }

    #endregion

}
