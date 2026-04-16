using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Governtree;
using System.Net;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.ExcelService;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class GoverntreeController : ControllerBase
{
    private readonly IRepositoryXL<GoverntreeProcedure, GoverntreeResult> _repository;
    private readonly IIdentityService _identityService;
    private readonly IExcelService _excelService;

    public GoverntreeController(IRepositoryXL<GoverntreeProcedure, GoverntreeResult> repository, IIdentityService identityService, IRepositoryS<AdminTempProcedure, AdminResult> adminRepo, IExcelService excelService)
    {
        _repository = repository;
        _identityService = identityService;
        _excelService = excelService;
    }

    //GET api/governtree/doc
    [HttpGet]
    [Route("doc")]
    public async Task<JsonResult> AllDoc()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/doc
    [HttpPut]
    [Route("doc")]
    public async Task<JsonResult> MainAdd([FromBody] GoverntreeProcedure model)
    {

        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //Delete api/governtree/doc
    [HttpDelete]
    [Route("doc")]
    public async Task<OkObjectResult> MainRemove([FromBody] GoverntreeProcedure model)
    {
        await _repository.Op_03(model);
        return new OkObjectResult(string.Format(@"Document was successfully removed"));
    }

    //POST api/governtree/reference
    [HttpPost]
    [Route("reference")]
    public async Task<JsonResult> References([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/reference
    [HttpPut]
    [Route("reference")]
    public async Task<JsonResult> ReferenceAdd([FromBody] GoverntreeProcedure model)
    {

        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/governtree/reference
    [HttpDelete]
    [Route("reference")]
    public async Task<OkObjectResult> ReferenceRemove([FromBody] GoverntreeProcedure model)
    {

        await _repository.Op_06(model);
        return new OkObjectResult(string.Format(@"Reference was successfully removed"));
    }

    //POST api/governtree/form
    [HttpPost]
    [Route("form")]
    //[ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Forms([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }



    //PUT api/governtree/form
    [HttpPut]
    [Route("form")]
    public async Task<JsonResult> FormAdd([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }


    //DELETE api/governtree/form
    [HttpDelete]
    [Route("form")]
    public async Task<OkObjectResult> FormRemove([FromBody] GoverntreeProcedure model)
    {
        await _repository.Op_09(model);
        return new OkObjectResult(string.Format(@"Form was successfully removed"));
    }

    //POST api/governtree/industry-standard-link
    [HttpPost]
    [Route("industry-standard-link")]
    public async Task<JsonResult> IndustryStandardLink([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/industry-standard-link
    [HttpPut]
    [Route("industry-standard-link")]
    public async Task<JsonResult> IndustryStandardLinkAdd([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }


    //DELETE api/governtree/industry-standard-link
    [HttpDelete]
    [Route("industry-standard-link")]
    public async Task<OkObjectResult> IndustryStandardLinkRemove([FromBody] GoverntreeProcedure model)
    {
        await _repository.Op_12(model);
        return new OkObjectResult(string.Format(@"Industry Standard link was successfully removed"));
    }

    //POST api/governtree/job-aid-link
    [HttpPost]
    [Route("job-aid-link")]
    public async Task<JsonResult> JobAidLinks([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/job-link
    [HttpPut]
    [Route("job-link")]
    public async Task<JsonResult> JobAidLinkAdd([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }


    //DELETE api/governtree/job-aid-link
    [HttpDelete]
    [Route("job-aid-link")]
    public async Task<OkObjectResult> JobAidLinkRemove([FromBody] GoverntreeProcedure model)
    {
        await _repository.Op_15(model);
        return new OkObjectResult(string.Format(@"Job Aid link was successfully removed"));
    }

    //POST api/governtree/dcr
    //Requires GTID
    [HttpPost]
    [Route("dcr")]
    public async Task<JsonResult> GetDCR([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/pucc
    //Requires GTID
    [HttpPost]
    [Route("pucc")]
    public async Task<JsonResult> GetPUCC([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/industry-standard
    [HttpGet]
    [Route("industry-standard")]
    public async Task<JsonResult> GetIndustryStandards()
    {
        var result = await _repository.Op_19();
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/industry-standard/section
    //Requires IndustryStandard
    [HttpPost]
    [Route("industry-standard/section")]
    public async Task<JsonResult> GetIndustryStandardSections([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/industry-standard/section/personnel
    //Requires IndustryStandardSectionID and PersonnelType
    //personnel is also called 'resource'
    [HttpPost]
    [Route("industry-standard/section/personnel")]
    public async Task<JsonResult> GetIndustryStandardSectionPersonnel([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/doc-no  
    [HttpGet]
    [Route("doc-no")]
    public async Task<JsonResult> GetDocumentNo()
    {
        var result = await _repository.Op_21();
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/industry-standard-no  
    [HttpGet]
    [Route("industry-standard-no")]
    public async Task<JsonResult> GetIndustryStandardNo()
    {
        var result = await _repository.Op_22();
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/job-aid-no 
    [HttpGet]
    [Route("job-aid-no")]
    public async Task<JsonResult> GetJobAidNo()
    {
        var result = await _repository.Op_23();
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/industry-standard/section/personnel
    [HttpPut]
    [Route("industry-standard/section/personnel")]
    public async Task<JsonResult> TCorTCS([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }


    //PUT api/governtree/industry-ledger
    [HttpPut]
    [Route("industry-ledger")]
    public async Task<JsonResult> NewIndustryStandard([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/job-aid-name
    [HttpPost]
    [Route("job-aid-name")]
    public async Task<JsonResult> JobAidCheck([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/job-aid
    [HttpPut]
    [Route("job-aid")]
    public async Task<JsonResult> JobAidAdd([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/governtree/oversight/process-owner
    [HttpPost]
    [Route("oversight/process-owner")]
    public async Task<JsonResult> GetProcessOwner([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/oversight/process-owner
    [HttpPut]
    [Route("oversight/process-owner")]
    public async Task<JsonResult> AddProcessOwner([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

    //Delete api/governtree/oversight/process-owner
    [HttpDelete]
    [Route("oversight/process-owner")]
    public async Task<JsonResult> RemoveProcessOwner([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/industry-standard/action
    [HttpPost]
    [Route("industry-standard/action")]
    public async Task<JsonResult> Actiontable([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/industry-standard/action
    [HttpPut]
    [Route("industry-standard/action")]
    public async Task<JsonResult> AddAction([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/governtree/industry-standard/action
    [HttpDelete]
    [Route("industry-standard/action")]
    public async Task<JsonResult> DeleteAction([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/doc-no-pand-s
    [HttpGet]
    [Route("doc-no/pand-s")]
    public async Task<JsonResult> DocSearch()
    {
        var result = await _repository.Op_34();
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/job-aid
    [HttpPost]
    [Route("job-aid")]
    public async Task<JsonResult> JobAid([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_35(model);
        return BaseResult.JsonResult(result);
    }


    //PUT api/governtree/job-aid-revision
    [HttpPut]
    [Route("job-aid-revision")]
    public async Task<JsonResult> NewJobAid([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_36(model);
        var ID = model.GTID;
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/resource-type
    [HttpGet]
    [Route("resource-type")]
    public async Task<JsonResult> getresourcetype()
    {
        var result = await _repository.Op_37();
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/resource-type
    [HttpPut]
    [Route("resource-type")]
    public async Task<JsonResult> AddResourcetype([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_38(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/governtree/resource-type
    [HttpDelete]
    [Route("resource-type")]
    public async Task<OkObjectResult> Deleteresourcetype([FromBody] GoverntreeProcedure model)
    {
        await _repository.Op_39(model);
        return new OkObjectResult(string.Format(@"Job Aid link was successfully removed"));
    }

    //GET api/governtree/org-type
    [HttpGet]
    [Route("org-type")]
    public async Task<JsonResult> getorgtype()
    {
        var result = await _repository.Op_40();
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/org-type
    [HttpPut]
    [Route("org-type")]
    public async Task<JsonResult> addorgtype([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_41(model);
        return BaseResult.JsonResult(result);
    }
    //DELTE api/governtree/org-type
    //add org type
    [HttpDelete]
    [Route("org-type")]
    public async Task<OkObjectResult> deleteorgtype([FromBody] GoverntreeProcedure model)
    {
        await _repository.Op_42(model);
        return new OkObjectResult(string.Format(@"Job Aid link was successfully removed"));
    }

    //PATCH api/governtree/job-aid-status
    //updated job aid status
    [HttpPatch]
    [Route("job-aid-status")]
    public async Task<JsonResult> updateJobaidstatus([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_43(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/industry-standard/section/description
    [HttpPut]
    [Route("industry-standard/section/description")]
    public async Task<JsonResult> UpdateISDescription([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_44(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/industry-standard/section/status-description
    [HttpPost]
    [Route("industry-standard/section/status-description")]
    public async Task<JsonResult> ISstatusdesc([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_45(model);
        return BaseResult.JsonResult(result);
    }
    //GET api/governtree/industry-status
    [HttpGet]
    [Route("industry-status")]
    public async Task<JsonResult> GetStatus()
    {
        var result = await _repository.Op_46();
        return BaseResult.JsonResult(result);
    }
    //GET api/governtree/job-aid-status
    [HttpGet]
    [Route("job-aid-status")]
    public async Task<JsonResult> GetJobAidStatus()
    {
        var result = await _repository.Op_47();
        return BaseResult.JsonResult(result);
    }

    //Delete api/governtree/industry-standard/resource
    [HttpDelete]
    [Route("industry-standard/resource")]
    public async Task<JsonResult> DeleteResource([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_48(model);
        return BaseResult.JsonResult(result);
    }

    //Delete api/governtree/industry-ledger
    [HttpDelete]
    [Route("industry-ledger")]
    public async Task<JsonResult> DeleteIL([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_49(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/governtree/industry-standard/action
    //update industry standard action
    [HttpPatch]
    [Route("industry-standard/action")]
    public async Task<JsonResult> UpdateISAction([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_50(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/doc-no-dynamic
    [HttpPost]
    [Route("doc-no-dynamic")]
    public async Task<JsonResult> GetDocNo([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_51(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/industry-standard/section/status
    [HttpPut]
    [Route("industry-standard/section/status")]
    public async Task<JsonResult> updateISstatus([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_52(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/process-health
    [HttpPost]
    [Route("process-health")]
    public async Task<JsonResult> GetProcessHealth([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_53(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/process-health
    [HttpPut]
    [Route("process-health")]
    public async Task<JsonResult> AddProcessHealth([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_54(model);
        return BaseResult.JsonResult(result);
    }

    //Delete api/governtree/process-health
    [HttpDelete]
    [Route("process-health")]
    public async Task<JsonResult> RemoveProcessHealth([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_55(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/doc-no-dynamic-verify
    [HttpPost]
    [Route("doc-no-dynamic-verify")]
    public async Task<JsonResult> DocNoDynamicVerify([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_56(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/governtree/export-process-health
    [HttpPost]
    [Route("export-process-health")]
    public async Task<IActionResult> ExporttoExcelProcessHealth(ExcelConvertRequest request)
    {
        var data = (await _repository.Op_57()).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }

    //GET api/governtree/process-health-matrix
    [HttpGet]
    [Route("process-health-matrix")]
    public async Task<JsonResult> GetProcessHealthMatrix()
    {
        var result = await _repository.Op_58();
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/process-health-version-history
    [HttpPost]
    [Route("process-health-version-history")]
    public async Task<JsonResult> GetProcessHealthVersionHistory([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_59(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/governtree/action-status
    [HttpGet]
    [Route("action-status")]
    public async Task<JsonResult> GetActionStatus()
    {
        var result = await _repository.Op_60();
        return BaseResult.JsonResult(result);
    }

    //POST api/governtree/actions
    [HttpPost]
    [Route("actions")]
    public async Task<JsonResult> GetProcessHealthActions([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_61(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/governtree/actions
    [HttpPut]
    [Route("actions")]
    public async Task<JsonResult> AddProcessHealthAction([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_62(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/governtree/actions
    [HttpPatch]
    [Route("actions")]
    public async Task<JsonResult> EditProcessHealthAction([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_63(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/governtree/actions
    [HttpDelete]
    [Route("actions")]
    public async Task<JsonResult> RemoveProcessHealthAction([FromBody] GoverntreeProcedure model)
    {
        var result = await _repository.Op_64(model);
        return BaseResult.JsonResult(result);
    }
}