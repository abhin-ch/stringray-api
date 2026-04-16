using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Specifications;

using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using System.Text.Json;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Requests.TOQ;
using StingrayNET.ApplicationCore.HelperFunctions;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
public class TOQController : BaseApiController
{
    private readonly IRepositoryL<Procedure, TOQResult> _repository;
    private readonly IBLOBServiceNew _blobService;
    private readonly ITOQService _tOQService;
    private readonly IEmailService _emailService;
    private readonly ITOQHelperFunctions _toqHelperFunctions;

    public TOQController(IRepositoryL<Procedure, TOQResult> repository,
        IIdentityService identityService, IBLOBServiceNew blobService, ITOQService tOQService, ITOQHelperFunctions toqHelperFunctions, IEmailService emailService) : base(identityService)
    {
        _repository = repository;
        _blobService = blobService;
        _tOQService = tOQService;
        _toqHelperFunctions = toqHelperFunctions;
        _emailService = emailService;
    }

    //GET api/toq/status
    [HttpGet]
    [Route("status")]
    public async Task<JsonResult> GetTOQStatus(string type, string statusValue, int tmid)
    {
        var values = Enum.GetValues<TOQType>().Select(e => e.ToString());
        if (!values.Contains(type))
        {
            throw new ArgumentException($"TOQ record type invalid; options are: {string.Join(",", values)}. Type received: {type}");
        }

        var request = new TOQStatusOptionsRequest
        {
            Type = type,
            TMID = tmid,
            StatusValue = statusValue
        };
        request.SetEmployeeID(HttpContext!.Items[@"EmployeeID"].ToString());
        var statusResult = await _tOQService.GetStatusOptions(request);
        return BaseResult.JsonResult<HttpSuccess>(statusResult);
    }

    //POST vendor-award/options
    [HttpPost]
    [Route("vendor-award/options")]
    public async Task<JsonResult> VendorAwardOptions([FromBody] Procedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/vendor-award
    [HttpPost]
    [Route("vendor-award")]
    public async Task<JsonResult> VendorAward([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/ebs-band
    [HttpGet]
    [Route("ebs-band")]
    public async Task<JsonResult> EBSBandAll()
    {
        var result = await _repository.Op_25(new Procedure { SubOp = 3 });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/ebs-band
    [HttpPost]
    [Route("ebs-band")]
    public async Task<JsonResult> EBSBand([FromBody] Procedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/ebs-band-rate
    [HttpPatch]
    [Route("ebs-band-rate")]
    public async Task<JsonResult> EBSBandRate([FromBody] Procedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/ebs-bin/type
    //No requirements
    [HttpGet]
    [Route("ebs-bin/type")]
    public async Task<JsonResult> EBSBinType()
    {
        var result = await _repository.Op_32(new Procedure { SubOp = 1 });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/ebs-bin
    //Requires TOQMainID (Value1)
    [HttpPost]
    [Route("ebs-bin")]
    public async Task<JsonResult> EBSBin([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 5;
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }


    //PUT api/toq/ebs-bin
    //Requires TOQMainID (Value1), BinningTypeID (Value2)
    //Comment (Value3) optional
    [HttpPut]
    [Route("ebs-bin")]
    public async Task<JsonResult> AddEBSBin([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 2;
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/ebs-bin
    //Requires UniqueID for TOQ_Binning (Value1)
    //BinningTypeID (Value2), Comment (Value3) optional
    [HttpPatch]
    [Route("ebs-bin")]
    public async Task<JsonResult> UpdateEBSBin([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 3;
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toq/ebs-bin
    [HttpDelete]
    [Route("ebs-bin")]
    public async Task<JsonResult> DeleteEBSBin([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 4;
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/toq/email-notification
    [HttpPost]
    [Route("email-notification")]
    public async Task<JsonResult> NotificationEmail([FromBody] Procedure model)
    {
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/status
    [HttpPost]
    [Route("status")]
    public async Task<JsonResult> ChangeTOQStatus([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        TOQResult result = await _repository.Op_01(model);

        await _toqHelperFunctions.StatusUpdateEmails(model, result);

        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/vendor/work-type
    [HttpGet]
    [Route("options/vendor/work-type")]
    public async Task<JsonResult> GetVendorWorkType()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 2 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/funding-source
    [HttpGet]
    [Route("options/funding-source")]
    public async Task<JsonResult> GetFundingSource()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 5 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/record-types
    [HttpGet]
    [Route("options/record-types")]
    public async Task<JsonResult> GetTOQTypes(string statusValue)
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 1, Value1 = statusValue });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/types
    [HttpGet]
    [Route("options/types")]
    public async Task<JsonResult> GetTypesforNewRequest()
    {
        var result = await _repository.Op_16(new Procedure { SubOp = 1 });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/options/types
    //Requires Value1 (Parent type) for Update Status options
    [HttpPost]
    [Route("options/types")]
    public async Task<JsonResult> GetTypes([FromBody] Procedure model)
    {
        model.SubOp = 2;
        return BaseResult.JsonResult(await _repository.Op_16(model));
    }

    //GET api/toq/options/phase
    [HttpGet]
    [Route("options/phase")]
    public async Task<JsonResult> GetPhaseOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 3 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/scope-managed-by
    [HttpGet]
    [Route("options/scope-managed-by")]
    public async Task<JsonResult> GetScopeManagedByOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 4 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/work-type
    [HttpGet]
    [Route("options/work-type")]
    public async Task<JsonResult> GetWorkTypeOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 6 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/vendor-submission
    [HttpGet]
    [Route("options/vendor-submission")]
    public async Task<JsonResult> GetVendorSubmissionOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 7 });
        return BaseResult.JsonResult(result);
    }

    // GET api/toq/options/status
    [HttpGet]
    [Route("options/status")]
    public async Task<JsonResult> GetTOQStatusOptions(string TypeValue)
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 9, Value1 = TypeValue });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/options/phase
    [HttpGet]
    [Route("options/vendor-correspondence/question-types")]
    public async Task<JsonResult> GetCorrespondenceOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 10 });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq
    [HttpPost]
    public async Task<JsonResult> CreateNewTOQRecord([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 1;
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq?type=Standard
    [HttpGet]
    public async Task<JsonResult> GetTOQMain(string type)
    {
        var result = await _tOQService.FetchData(HttpContext!.Items[@"EmployeeID"].ToString(), type);
        return result;
    }

    //POST api/toq/main
    [HttpPost]
    [Route("main")]
    public async Task<JsonResult> GetTOQMain([FromBody] Procedure model)
    {
        model.SubOp = 6;
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/emergent
    [HttpGet]
    [Route("emergent")]
    public async Task<JsonResult> GetTOQEmergent(string uniqueID)
    {
        var result = await _repository.Op_05(new Procedure { SubOp = 2, Value1 = uniqueID });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/children
    //Requires Value1 (Parent UniqueID)
    [HttpPost]
    [Route("children")]
    public async Task<JsonResult> GetTOQChildren([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 7;
        return BaseResult.JsonResult(await _repository.Op_05(model));
    }

    //GET api/toq/header/qa/emergent
    [HttpGet]
    [Route("header/qa/emergent")]
    public async Task<JsonResult> GetTOQEmergentQA(string uniqueID)
    {
        var result = await _repository.Op_05(new Procedure { SubOp = 5, Value1 = uniqueID });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/header/qa
    [HttpPost]
    [Route("header/qa")]
    public async Task<JsonResult> GetTOQQA([FromBody] Procedure model)
    {
        model.SubOp = 4;
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/toq/emergent
    [HttpPost]
    [Route("emergent/additional")]
    public async Task<JsonResult> CreateAdditionalEmergent([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 2;
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/emergent
    [HttpPost]
    [Route("emergent/toq")]
    public async Task<JsonResult> CreateTOQForEmergent([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 3;
        var result = await _repository.Op_03(model);


        return BaseResult.JsonResult(result);
    }

    //GET api/toq/emergent-toq?uniqueID=
    [HttpGet]
    [Route("emergent-toq")]
    public async Task<JsonResult> GetTOQEmergentTOQ(string uniqueID)
    {
        var result = await _repository.Op_05(new Procedure { SubOp = 3, Value1 = uniqueID });
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/header
    [HttpPatch]
    [Route("header")]
    public async Task<JsonResult> SaveTDSHeader([FromBody] Procedure model)
    {
        if (model.SubOp is 1 or 2)
        {
            var result = await _repository.Op_07(model);
            return BaseResult.JsonResult(result);
        }
        return BaseResult.JsonResult<HttpError>("Invalid SubOp entered. Values 1 or 2 are valid.");
    }

    //PATCH api/toq/emergent/header
    [HttpPatch]
    [Route("emergent/header")]
    public async Task<JsonResult> SaveEmergentTDSHeader([FromBody] Procedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/header/mpl
    [HttpPatch]
    [Route("header/mpl")]
    public async Task<JsonResult> SaveMPLDetails([FromBody] Procedure model)
    {
        model.SubOp = 3;
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult<HttpSuccess>(result);
    }

    //PATCH api/toq/header/qa
    [HttpPatch]
    [Route("header/qa")]
    public async Task<JsonResult> SaveTOQQA([FromBody] Procedure model)
    {
        model.SubOp = 5;
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult<HttpSuccess>(result);
    }

    //GET api/toq/vendor-correspondence
    [HttpGet]
    [Route("vendor-correspondence")]
    public async Task<JsonResult> ViewVendorCorrespondence(string id)
    {
        var model = new Procedure { Value1 = id };
        model.SubOp = 1;
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/vendor-correspondence/question
    [HttpPost]
    [Route("vendor-correspondence/question")]
    public async Task<JsonResult> AddVendorCorrespondenceQ([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 2;
        TOQResult result = await _repository.Op_06(model);

        await _toqHelperFunctions.VCQuestionEmail(model);

        return BaseResult.JsonResult(result);
    }

    //POST api/toq/vendor-correspondence/answer
    [HttpPost]
    [Route("vendor-correspondence/answer")]
    public async Task<JsonResult> AddVendorCorrespondenceA([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 3;
        TOQResult result = await _repository.Op_06(model);

        await _toqHelperFunctions.VCAnswerEmail(model);

        return BaseResult.JsonResult(result);
    }

    //POST api/toq/vendor-correspondence/date-extension
    [HttpPost]
    [Route("vendor-correspondence/date-extension")]
    public async Task<JsonResult> VendorCorrespondenceDateExtension([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 7;
        TOQResult result = await _repository.Op_06(model);

        await _toqHelperFunctions.VCDateExtensionEmail(model);

        return BaseResult.JsonResult(result);
    }

    //POST api/toq/oe-correspondence/date-extension
    [HttpPost]
    [Route("oe-correspondence/date-extension")]
    public async Task<JsonResult> OECorrespondenceDateExtension([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 9;
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/correspondence/answer
    [HttpGet]
    [Route("correspondence/date-extension/answer")]
    public async Task<JsonResult> GetCorrespondenceAsnwer(string uniqueID)
    {
        var model = new Procedure { Value1 = uniqueID };
        model.SubOp = 8;
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/oe-correspondence
    [HttpGet]
    [Route("oe-correspondence")]
    public async Task<JsonResult> ViewOEVendorCorrespondence(string id)
    {
        var model = new Procedure { Value1 = id };
        model.SubOp = 4;
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/oe-correspondence/question
    [HttpPost]
    [Route("oe-correspondence/question")]
    public async Task<JsonResult> AddOECorrespondenceQ([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 5;
        TOQResult result = await _repository.Op_06(model);

        await _toqHelperFunctions.OEQuestionEmail(model);

        return BaseResult.JsonResult(result);
    }

    //POST api/toq/oe-correspondence/answer
    [HttpPost]
    [Route("oe-correspondence/answer")]
    public async Task<JsonResult> AddOECorrespondenceA([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 6;
        TOQResult result = await _repository.Op_06(model);

        await _toqHelperFunctions.OEAnswerEmail(model);

        return BaseResult.JsonResult(result);
    }

    //GET api/toq/classv/options
    [HttpGet]
    [Route("classv/options")]
    public async Task<JsonResult> GetClassVOptions()
    {
        var result = await _repository.Op_08(new Procedure { SubOp = 7 });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/classv/main
    [HttpPost]
    [Route("classv/main")]
    public async Task<JsonResult> NewClassV([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 1;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/classv/main/copy
    [HttpPost]
    [Route("classv/main/copy")]
    public async Task<JsonResult> DuplicateClassV([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 6;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/classv/main
    [HttpGet]
    [Route("classv/main")]
    public async Task<JsonResult> GetClassVMain(int tmid)
    {
        var model = new Procedure
        {
            EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString(),
            SubOp = 5,
            Num1 = tmid
        };
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/classv
    [HttpGet]
    [Route("classv")]
    public async Task<JsonResult> GetClassV(string uid)
    {
        var model = new Procedure
        {
            Value1 = uid,
            SubOp = 8
        };
        TOQResult result = await _repository.Op_08(model);
        result = _toqHelperFunctions.CountHourClassV(result);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toq/classv/main
    [HttpDelete]
    [Route("classv/main")]
    public async Task<JsonResult> DeleteClassVEstimate([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 9;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/classv/main/link
    [HttpPost]
    [Route("classv/main/link")]
    public async Task<JsonResult> LinkClassV([FromBody] Procedure model)
    {
        model.SubOp = 10;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/classv/main/summary
    [HttpPost]
    [Route("classv/main/summary")]
    public async Task<JsonResult> GetClassVSummary([FromBody] Procedure model)
    {
        model.SubOp = 11;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/classv/main/title
    [HttpPatch]
    [Route("classv/main/title")]
    public async Task<JsonResult> UpdateClassVTitle([FromBody] Procedure model)
    {
        model.SubOp = 13;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/classv/qty
    [HttpPatch]
    [Route("classv/qty")]
    public async Task<JsonResult> UpdateClassVQty([FromBody] Procedure model)
    {
        model.SubOp = 4;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/classv/resource
    [HttpPatch]
    [Route("classv/resource")]
    public async Task<JsonResult> UpdateClassVResource([FromBody] Procedure model)
    {
        model.SubOp = 3;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/classv/complexity
    [HttpPatch]
    [Route("classv/complexity")]
    public async Task<JsonResult> UpdateClassVComplexity([FromBody] Procedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/status/validate
    [HttpPost]
    [Route("status/validate")]
    public async Task<JsonResult> ValidateTOQStatus([FromBody] Procedure model)
    {
        var result = await _repository.Op_09(model);
        var isValid = TOQResult.ValidateStatus(model.Value1, result);
        return BaseResult.JsonResult<HttpSuccess>(isValid);
    }

    //POST api/toq/vendor/make-editable
    [HttpPost]
    [Route("vendor/make-editable")]
    public async Task<JsonResult> MakeEditable([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult<HttpSuccess>(result);
    }

    //GET api/toq/status-log
    [HttpGet]
    [Route("status-log")]
    public async Task<JsonResult> StatusLog(string id)
    {
        var result = await _repository.Op_01(new Procedure { Value1 = id, SubOp = 1 });
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/vendor-assigned
    [HttpPost]
    [Route("vendor-assigned")]
    public async Task<JsonResult> InsertVendorAssigned([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/vendor-assigned
    [HttpPatch]
    [Route("vendor-assigned")]
    public async Task<JsonResult> AwardVendor([FromBody] Procedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/vendor-assigned/view
    [HttpPost]
    [Route("vendor-assigned/view")]
    public async Task<JsonResult> GetVendorAssigned([FromBody] Procedure model)
    {
        model.SubOp = 3;
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/tds/attachment
    [HttpGet]
    [Route("tds/attachment")]
    public async Task<JsonResult> GetTDSAttachments(string parentID)
    {
        var result = await _repository.Op_12(new Procedure { SubOp = 1, Value1 = parentID });
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/tds/attachment
    [HttpPatch]
    [Route("tds/attachment")]
    public async Task<JsonResult> UpdateTDSAttachmentArchive([FromBody] Procedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toq/tds/attachment
    [HttpDelete]
    [Route("tds/attachment")]
    public async Task<JsonResult> DeleteTDSAttachmentArchive([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/mpl/personnel
    [HttpGet]
    [Route("mpl/personnel")]
    public async Task<JsonResult> GetMPLPersonnel(string projectID)
    {
        var result = await _repository.Op_13(new Procedure { Value1 = projectID });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/header/qa/options
    [HttpGet]
    [Route("header/qa/options")]
    public async Task<JsonResult> GetQAOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 8 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/header/qa/options
    [HttpGet]
    [Route("header/project/options")]
    public async Task<JsonResult> GetProjectOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 12 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/vendor-submission
    [HttpGet]
    [Route("vendor-submission")]
    public async Task<JsonResult> GetVendorAssigned(string uniqueID)
    {
        var result = await _repository.Op_02(new Procedure { Value1 = uniqueID, SubOp = 4 });
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/vendor-submission
    [HttpGet]
    [Route("vendor-submission/validate")]
    public async Task<JsonResult> GetVendorAssignedValidate(string uniqueID)
    {
        var result = await _repository.Op_02(new Procedure { Value1 = uniqueID, SubOp = 8 });
        var result2 = await _repository.Op_02(new Procedure { Value1 = uniqueID, SubOp = 9 });
        var result3 = await _repository.Op_02(new Procedure { Value1 = uniqueID, SubOp = 10 });

        string headerError = null!;
        string costError = null!;
        string vsAttachmentError = null!;

        var json = JsonSerializer.Serialize(result.Data1[0]);
        var vendor = JsonSerializer.Deserialize<TOQVendorSubmission>(json);

        var isHeaderValid = false;

        if (vendor is not null && vendor.IsValid())
        {
            isHeaderValid = true;
        }
        else
        {
            headerError = vendor?.ErrorMessage ?? "";
        }

        var isCostValid = false;
        if (result2.Data1.Count > 0)
        {
            // Deserialize the cost summaries
            var costSummaries = result2.Data1.Select(x =>
            {
                var json = JsonSerializer.Serialize(x);
                return JsonSerializer.Deserialize<TOQCostSummary>(json);
            }).ToList();

            // Sum TotalCost and validate
            var sumCost = costSummaries.Sum(x => x.TotalCost);

            // Check sum total cost is greater than 0
            if (sumCost <= 0)
            {
                costError = "Cost summary has not been provided.";
            }

            // Check each row's DQ validation;
            var invalidRow = costSummaries.FirstOrDefault(x => !x.IsValid());
            if (invalidRow != null)
            {
                costError = "New TOQ Commitment Date is required for rows with a DQ or NDQ commitment";
            }

            // Validate dates for each row
            foreach (var item in costSummaries)
            {
                var deliverableEndDate = item?.DeliverableEndDate;
                var newTOQCommitmentDate = item?.NewTOQCommitmentDate;
                var toqEndDate = item?.TOQEndDate;

                // Ensure DeliverableEndDate and NewTOQCommitmentDate are not after TOQEndDate
                if ((deliverableEndDate != null && deliverableEndDate > toqEndDate) ||
                    (newTOQCommitmentDate != null && newTOQCommitmentDate > toqEndDate))
                {
                    costError = "Deliverable End Date or New TOQ Commitment Date cannot be after TOQ End Date";
                }
            }

            // Only mark cost as valid if no error was set
            if (string.IsNullOrEmpty(costError))
            {
                isCostValid = true;
            }
        }
        var isVSAttachmentIncluded = false;
        if (result3.Data1.Count > 0)
        {
            var json3 = JsonSerializer.Serialize(result3.Data1[0]);
            var fileMeta = JsonSerializer.Deserialize<FileMeta>(json3);
            if (fileMeta is not null)
            {
                isVSAttachmentIncluded = true;
            }
            else
            {
                vsAttachmentError = "Vendor Attachment missing";
            }
        }
        else
        {
            vsAttachmentError = "Vendor Attachment missing";

        }

        var validation = new { isValid = isHeaderValid && isCostValid && isVSAttachmentIncluded, headerError, costError, vsAttachmentError };
        return BaseResult.JsonResult<HttpSuccess>(validation);
    }

    //GET api/toq/vs/status-log
    [HttpPost]
    [Route("vs/status-log")]
    public async Task<JsonResult> GetQAOptions([FromBody] Procedure model)
    {
        model.SubOp = 7;
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/vendor-submission/status
    [HttpPost]
    [Route("vendor-submission/status")]
    public async Task<JsonResult> VendorSubmissionStatusChange([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        TOQResult result = await _repository.Op_20(model);

        await _toqHelperFunctions.SubupEmails(model, result);

        return BaseResult.JsonResult(result);
    }


    //POST api/toq/vs/header
    [HttpPost]
    [Route("vs/header")]
    public async Task<JsonResult> SaveVendorHeader([FromBody] Procedure model)
    {
        switch (model.SubOp)
        {
            case 5:
            case 6:
                {
                    break;
                }
            default:
                throw new ArgumentException($"Attempt to save VendorSubmission details, SubOp 5 or 6 accepted. Received SubOp={model.SubOp}");
        }
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/toq/QAOptions
    [HttpGet]
    [Route("admin-tool/toq/QAOptions")]
    public async Task<JsonResult> GetTOQQAOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 1;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/toq/PhaseOptions
    [HttpGet]
    [Route("admin-tool/toq/PhaseOptions")]
    public async Task<JsonResult> GetTOQPhaseOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 2;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/toq/QuestionTypeOptions
    [HttpGet]
    [Route("admin-tool/toq/QuestionTypeOptions")]
    public async Task<JsonResult> GetQuestionTypeOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 3;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/toq/QuestionTypeOptions
    [HttpGet]
    [Route("admin-tool/toq/ReasonForTOQOptions")]
    public async Task<JsonResult> GetReasonForTOQ()
    {
        Procedure model = new Procedure();
        model.SubOp = 4;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/toq/FundingTypeOptions
    [HttpGet]
    [Route("admin-tool/toq/FundingTypeOptions")]
    public async Task<JsonResult> GetFundingTypeTOQ()
    {
        Procedure model = new Procedure();
        model.SubOp = 5;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/toq/ReasonNotSelectedOptions
    [HttpGet]
    [Route("admin-tool/toq/ReasonNotSelectedOptions")]
    public async Task<JsonResult> GetTOQReasonNotSelectedOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 6;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/emergent/QAOptions
    [HttpGet]
    [Route("admin-tool/emergent/QAOptions")]
    public async Task<JsonResult> GetEmergentQAOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 7;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/emergent/FundingSourceOptions
    [HttpGet]
    [Route("admin-tool/emergent/FundingSourceOptions")]
    public async Task<JsonResult> GetEmergentFundingSourceOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 8;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/svn/ScopeReasonOptions
    [HttpGet]
    [Route("admin-tool/svn/ScopeReasonOptions")]
    public async Task<JsonResult> GetSVNScopeReasonOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 9;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/admin-tool/svn/TrendReasonOptions
    [HttpGet]
    [Route("admin-tool/svn/TrendReasonOptions")]
    public async Task<JsonResult> GetSVNTrendReasonOptions()
    {
        Procedure model = new Procedure();
        model.SubOp = 10;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/admin-tool/remove-toqoption
    [HttpPatch]
    [Route("admin-tool/remove-toqoption")]
    public async Task<JsonResult> RemoveTOQOption([FromBody] Procedure model)
    {
        model.SubOp = 11;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/admin-tool/activate-toqoption
    [HttpPatch]
    [Route("admin-tool/activate-toqoption")]
    public async Task<JsonResult> ActivateTOQOption([FromBody] Procedure model)
    {
        model.SubOp = 12;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/admin-tool/edit-toqoption
    [HttpPatch]
    [Route("admin-tool/edit-toqoption")]
    public async Task<JsonResult> EditTOQOption([FromBody] Procedure model)
    {
        model.SubOp = 13;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/toq/admin-tool/add-toqoption
    [HttpPut]
    [Route("admin-tool/add-toqoption")]
    public async Task<JsonResult> AddTOQOption([FromBody] Procedure model)
    {
        model.SubOp = 14;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/admin-tool/toqreorder
    [HttpPatch]
    [Route("admin-tool/toqreorder")]
    public async Task<JsonResult> AdminToolReorder([FromBody] Procedure model)
    {
        model.SubOp = 15;
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }


    //Post api/toq/emergent/header
    [HttpPost]
    [Route("emergent/header")]
    public async Task<JsonResult> EmergentGetHeader([FromBody] Procedure model)
    {
        model.SubOp = 2;
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    // GET api/toq/options/deliverables
    [HttpGet]
    [Route("options/deliverables")]
    public async Task<JsonResult> GetDeliverableOptions()
    {
        var result = await _repository.Op_04(new Procedure { SubOp = 11 });
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/emergent/relink
    [HttpPost]
    [Route("emergent/relink")]
    public async Task<JsonResult> EmergentRelink([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/svn/header
    [HttpPatch]
    [Route("svn/header")]
    public async Task<JsonResult> SVNSaveHeader([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/svn/header
    [HttpPost]
    [Route("svn/header")]
    public async Task<JsonResult> SVNGetHeader([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    // GET api/toq/partial
    [HttpGet]
    [Route("partial")]
    public async Task<JsonResult> GetPartialRequests(string VendorAssignedID)
    {
        var result = await _repository.Op_19(new Procedure { SubOp = 1, Value1 = VendorAssignedID });
        return BaseResult.JsonResult(result);
    }

    // POST api/toq/partial
    [HttpPost]
    [Route("partial")]
    public async Task<JsonResult> AddPartialRequest([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    // DELETE api/toq/partial
    [HttpDelete]
    [Route("partial")]
    public async Task<JsonResult> DeletePartialRequest([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    // GET api/toq/cost-summary
    [HttpGet]
    [Route("cost-summary")]
    public async Task<JsonResult> GetCostSummary(string VendorAssignedID)
    {
        var result = await _repository.Op_21(new Procedure { SubOp = 1, Value1 = VendorAssignedID });
        return BaseResult.JsonResult(result);
    }

    // POST api/toq/cost-summary
    [HttpPost]
    [Route("cost-summary")]
    public async Task<JsonResult> AddCostSummaryItem([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    // PATCH api/toq/cost-summary
    [HttpPatch]
    [Route("cost-summary")]
    public async Task<JsonResult> UpdateCostSummaryItem([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    // DELETE api/toq/cost-summary
    [HttpDelete]
    [Route("cost-summary")]
    public async Task<JsonResult> DeleteCostSummaryItem([FromBody] Procedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    // GET api/toq/rework
    [HttpPost]
    [Route("rework")]
    public async Task<JsonResult> GetReworkHeader([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    // PATCH api/toq/rework
    [HttpPatch]
    [Route("rework")]
    public async Task<JsonResult> UpdateRework([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }



    //Post api/toq/svn/deliverable
    [HttpPost]
    [Route("svn/deliverable")]
    public async Task<JsonResult> SVNGetDeliverable([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/svn/deliverable
    [HttpPatch]
    [Route("svn/deliverable")]
    public async Task<JsonResult> SVNUpdateDeliverable([FromBody] Procedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/svn/cs-deliverable
    [HttpPost]
    [Route("svn/cs-deliverable")]
    public async Task<JsonResult> SVNAddCSDeliverable([FromBody] Procedure model)
    {
        model.SubOp = 5;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/emergent/resolve
    [HttpPost]
    [Route("emergent/resolve")]
    public async Task<JsonResult> EmergentUpdatetoRES([FromBody] Procedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/ram/revision
    [HttpPost]
    [Route("ram/revision")]
    public async Task<JsonResult> GetRAMRevision([FromBody] Procedure model)
    {
        model.SubOp = 1;
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toq/ram/revision
    [HttpPatch]
    [Route("ram/revision")]
    public async Task<JsonResult> EditRAMRevision([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/ram/allfields
    [HttpPost]
    [Route("ram/all-fields")]
    public async Task<JsonResult> RAMAllFields([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/pdeEstimate
    [HttpPatch]
    [Route("ram/pde-estimate")]
    public async Task<JsonResult> RAMUpdate([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/pde-estimate/ebs
    [HttpPatch]
    [Route("ram/pde-estimate/ebs")]
    public async Task<JsonResult> RAMEBSUpdate([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/comparison
    [HttpPatch]
    [Route("ram/comparison")]
    public async Task<JsonResult> RAMComparisonUpdate([FromBody] Procedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/ram/budget-summary
    [HttpPost]
    [Route("ram/budget-summary")]
    public async Task<JsonResult> RAMBudgetSummary([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/budget-summary
    [HttpPatch]
    [Route("ram/budget-summary-part-1")]
    public async Task<JsonResult> RAMBudgetSummaryUpdate([FromBody] Procedure model)
    {
        model.SubOp = 2;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }
    //Patch api/toq/ram/budget-summary
    [HttpPatch]
    [Route("ram/budget-summary-part-2")]
    public async Task<JsonResult> RAMBudgetSummaryUpdate2([FromBody] Procedure model)
    {
        model.SubOp = 3;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }
    //Patch api/toq/ram/budget-summary
    [HttpPatch]
    [Route("ram/budget-summary-part-3")]
    public async Task<JsonResult> RAMBudgetSummaryUpdate3([FromBody] Procedure model)
    {
        model.SubOp = 4;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/ram/budgetform/design-discipline
    [HttpPost]
    [Route("ram/budgetform/design-discipline")]
    public async Task<JsonResult> InsertRAMDesigndiscipline([FromBody] Procedure model)
    {
        model.SubOp = 5;
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/ram/budgetform/design-discipline
    [HttpGet]
    [Route("ram/budgetform/design-discipline")]
    public async Task<JsonResult> GetRAMDesigndiscipline(string TOQMainID)
    {
        var result = await _repository.Op_15(new Procedure { SubOp = 6, Value1 = TOQMainID });
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/budgetform/design-discipline
    [HttpPatch]
    [Route("ram/budgetform/design-discipline")]
    public async Task<JsonResult> UpdateRAMDesigndiscipline([FromBody] Procedure model)
    {
        model.SubOp = 7;
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/ram/budgetform/design-support
    [HttpPost]
    [Route("ram/budgetform/design-support")]
    public async Task<JsonResult> InsertRAMDesignsupport([FromBody] Procedure model)
    {
        model.SubOp = 8;
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/ram/budgetform/design-support
    [HttpGet]
    [Route("ram/budgetform/design-support")]
    public async Task<JsonResult> GetRAMDesignsupport(string TOQMainID)
    {
        var result = await _repository.Op_15(new Procedure { SubOp = 9, Value1 = TOQMainID });
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/budgetform/design-support
    [HttpPatch]
    [Route("ram/budgetform/design-support")]
    public async Task<JsonResult> UpdateRAMDesignsupport([FromBody] Procedure model)
    {
        model.SubOp = 10;
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toq/ram/budgetform/cost-allocations
    [HttpPost]
    [Route("ram/budgetform/cost-allocations")]
    public async Task<JsonResult> InsertRAMCostAllocations([FromBody] Procedure model)
    {
        model.SubOp = 11;
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/ram/budgetform/cost-allocations
    [HttpGet]
    [Route("ram/budgetform/cost-allocations")]
    public async Task<JsonResult> GetRAMCostAllocations(string TOQMainID)
    {
        var result = await _repository.Op_15(new Procedure { SubOp = 12, Value1 = TOQMainID });
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/budgetform/cost-allocations
    [HttpPatch]
    [Route("ram/budgetform/cost-allocations")]
    public async Task<JsonResult> UpdateRAMCostAllocations([FromBody] Procedure model)
    {
        model.SubOp = 13;
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    // DELETE api/toq/cost-summary
    [HttpDelete]
    [Route("ram/budgetform/cost-allocations")]
    public async Task<JsonResult> DeleteRAMCostAllocations([FromBody] Procedure model)
    {
        model.SubOp = 14;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/ram/vendor-comparison
    [HttpPost]
    [Route("ram/vendor-comparison")]
    public async Task<JsonResult> RAMVendorComparison([FromBody] Procedure model)
    {
        model.SubOp = 1;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }
    //Get api/toq/ram/vendor-comparison
    [HttpGet]
    [Route("ram/vendor-comparison")]
    public async Task<JsonResult> GetRAMVendorComparison(string UniqueID)
    {
        var result = await _repository.Op_31(new Procedure { SubOp = 2, Value1 = UniqueID });
        return BaseResult.JsonResult(result);
    }

    //Patch api/toq/ram/vendor-comparison
    [HttpPatch]
    [Route("ram/vendor-comparison")]
    public async Task<JsonResult> PatchRAMVendorComparison([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        model.SubOp = 3;
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }
    //Post api/toq/pdf/report
    [HttpPost]
    [Route("pdf/report")]
    public async Task<JsonResult> PDFReport([FromBody] Procedure model)
    {
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/emergent/report
    [HttpPost]
    [Route("emergent/report")]
    public async Task<JsonResult> EmergentReport([FromBody] Procedure model)
    {
        model.SubOp = 5;
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/deliverable-account/vendors
    [HttpGet]
    [Route("deliverable-account/vendors")]
    public async Task<JsonResult> DeliverableAccount_Vendors()
    {
        var model = new Procedure { SubOp = 1 };
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/deliverable-account/toq
    [HttpGet]
    [Route("deliverable-account/toq")]
    public async Task<JsonResult> DeliverableAccount_TOQ(string vendorID)
    {
        var model = new Procedure { SubOp = 2, Value1 = vendorID };
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/deliverable-account/deliverables
    [HttpGet]
    [Route("deliverable-account/deliverables")]
    public async Task<JsonResult> DeliverableAccount_Deliverables(string toqMainID)
    {
        var model = new Procedure { SubOp = 3, Value1 = toqMainID };
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/deliverable-account/searchall
    [HttpGet]
    [Route("deliverable-account/searchall")]
    public async Task<JsonResult> DeliverableAccount_SearchAll(bool isVendor)
    {
        var model = new Procedure { SubOp = 4, IsTrue1 = isVendor, EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString() };
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toq/partials/checksum
    [HttpGet]
    [Route("partials/checksum")]
    public async Task<JsonResult> Partial_CheckSum(string toqMainID)
    {
        var model = new Procedure { Value1 = toqMainID };
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/svn/parent
    [HttpPost]
    [Route("svn/parent")]
    public async Task<JsonResult> SVNGetParent([FromBody] Procedure model)
    {
        model.SubOp = 6;
        model.EmployeeID = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/emergent/validation
    [HttpPost]
    [Route("emergent/validation")]
    public async Task<JsonResult> EmergentValidation([FromBody] Procedure model)
    {
        model.SubOp = 6;
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/svn/validation
    [HttpPost]
    [Route("svn/validation")]
    public async Task<JsonResult> SVNValidation([FromBody] Procedure model)
    {
        model.SubOp = 7;
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/erp
    [HttpPost]
    [Route("erp")]
    public async Task<JsonResult> ERPUpdated([FromBody] Procedure model)
    {
        var result = await _repository.Op_35(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/toq/emergent/personnel
    [HttpPost]
    [Route("emergent/personnel")]
    public async Task<JsonResult> EmergentPersonnel([FromBody] Procedure model)
    {
        model.SubOp = 7;
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    #region Legacy Doc Upload
    [AllowAnonymous]
    [HttpGet]
    [Route(@"legacy-file-upload")]
    public async Task LegacyFileUpload()
    {
        await _blobService.Upload(HttpContext!, @"TOQ", Department.DED, true);
    }



    #endregion
}
