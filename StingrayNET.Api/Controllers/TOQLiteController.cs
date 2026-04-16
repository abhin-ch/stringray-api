using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.TOQLite;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class TOQLiteController : ControllerBase
{
    private readonly IRepositoryXL<TOQLiteProcedure, TOQLiteResult> _repository;

    private readonly IRepositoryS<AdminTempProcedure, AdminResult> _adminRepo;

    public TOQLiteController(IRepositoryXL<TOQLiteProcedure, TOQLiteResult> repository, IRepositoryS<AdminTempProcedure, AdminResult> adminRepo)
    {

        _repository = repository;
        _adminRepo = adminRepo;
    }

    //POST api/toqlite
    //No params
    [HttpPost]
    public async Task<JsonResult> MainTable([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toqlite/section
    //No Params
    [HttpGet]
    [Route("section")]
    public async Task<JsonResult> GetSections()
    {
        var result = await _repository.Op_02();
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/project
    //Takes ProjectNo string argument 
    [HttpPost]
    [Route("project")]

    public async Task<JsonResult> GetProjectSuggestions([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/bp/deliverable
    //Takes TOQLiteID string argument 
    [HttpPost]
    [Route("bp/deliverable")]

    public async Task<JsonResult> GetBPDeliverables([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toqlite/vendor --  to get the vendor 
    //No Params
    [HttpGet]
    [Route("vendor")]

    public async Task<JsonResult> GetVendors()
    {
        var result = await _repository.Op_05();
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/toq
    //Takes VendorShort string
    [HttpPost]
    [Route("toq")]

    public async Task<JsonResult> GetTOQs([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/vendor/deliverable
    //Takes TOQLiteID string argument
    [HttpPost]
    [Route("vendor/deliverable")]

    public async Task<JsonResult> GetVendorDeliverables([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/vendor/deliverable/activity
    //Takes VendorDeliverableID number argument
    [HttpPost]
    [Route("vendor/deliverable/activity")]

    public async Task<JsonResult> GetVendorDeliverableActivities([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toqlite
    //DO NOT USE FOR NOW 
    [HttpPatch]
    public async Task<OkObjectResult> SaveMain([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_09(model);
        return new OkObjectResult(string.Format(@"TOQLite {0} successfully updated", model.TOQLiteID));
    }

    //PUT api/toqlite/bp/deliverable
    //Takes TOQLiteID string argument and Deliverable string argument
    [HttpPut]
    [Route("bp/deliverable")]

    public async Task<JsonResult> AddBPDeliverables([FromBody] TOQLiteProcedure model)
    {

        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/toqlite
    //Takes ER string argument
    [HttpPut]

    public async Task<JsonResult> AddTOQLite([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/bp/deliverable
    //Takes BPDeliverableID int argument
    [HttpDelete]
    [Route("bp/deliverable")]

    public async Task<OkObjectResult> RemoveBPDeliverable([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_12(model);
        return new OkObjectResult(string.Format(@"BP Deliverable {0} was successfully removed", model.BPDeliverableID));
    }

    //PATCH api/toqlite/bp/deliverable
    //Takes BPDeliverableID int argument plus all editable fields
    [HttpPatch]
    [Route("bp/deliverable")]

    public async Task<OkObjectResult> EditBPDeliverable([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_13(model);
        return new OkObjectResult(string.Format(@"BP Deliverable {0} was successfully updated", model.BPDeliverableID));
    }

    //PUT api/toqlite/vendor/deliverable/clone
    //Takes TOQLiteID string argument
    [HttpPut]
    [Route("vendor/deliverable/clone")]

    public async Task<JsonResult> CopyBPtoVendorDeliverables([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toqlite/vendor/deliverable
    //DO NOT USE FOR NOW
    [HttpPatch]
    [Route("vendor/deliverable")]

    public async Task<OkObjectResult> EditVendorDeliverable([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_15(model);
        return new OkObjectResult(string.Format(@"Vendor Deliverable {0} was successfully updated", model.VendorDeliverableID));
    }

    //PUT api/toqlite/vendor/deliverable
    //Requires DeliverableID (Which is actually called Deliverable) and TOQLiteID
    [HttpPut]
    [Route("vendor/deliverable")]

    public async Task<JsonResult> AddVendorDeliverable([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/er
    //Takes ER string as an argument
    [HttpPost]
    [Route("er")]

    public async Task<JsonResult> VerifyER([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/er/search
    //Takes ER string as an argument
    [HttpPost]
    [Route("er/search")]

    public async Task<JsonResult> SearchER([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/toqlite/deliverable
    [HttpGet]
    [Route("deliverable")]
    public async Task<JsonResult> StandardDeliverables()
    {
        var result = await _repository.Op_19();
        return BaseResult.JsonResult(result);
    }

    //PUT api/toqlite/vendor/deliverable/activity
    //Requires VendorDeliverableID, Activity (string), and ActivityHours (floating point)
    [HttpPut]
    [Route("vendor/deliverable/activity")]
    public async Task<OkObjectResult> AddActivity([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_20(model);
        return new OkObjectResult(string.Format(@"New activity successfully added for Vendor Deliverable ID {0}", model.VendorDeliverableID));
    }

    //DELETE api/toqlite/vendor/deliverable/activity
    //Requires VendorDeliverableActivityID
    [HttpDelete]
    [Route("vendor/deliverable/activity")]
    public async Task<OkObjectResult> RemoveActivity([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_21(model);
        return new OkObjectResult(string.Format(@"Activity {0} successfully removed", model.VendorDeliverableActivityID));
    }

    //PATCH api/toqlite/vendor/deliverable/activity
    //Requires VendorDeliverableActivityID, Activity (string), ActivityHours (floating point), and/or Activity50PCT (date) and Activity90PCT (date)
    [HttpPatch]
    [Route("vendor/deliverable/activity")]
    public async Task<JsonResult> EditActivity([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toqlite/status
    //Requires TOQLiteID, StatusShort. Comment is optional.
    [HttpPatch]
    [Route("status")]
    public async Task<JsonResult> ChangeStatus([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/status
    //Requires TOQLiteID
    [HttpPost]
    [Route("status")]
    public async Task<JsonResult> GetStatus([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //TODO - CENTRALIZE; GET THIS OUT OF THIS CONTROLLER
    //GET api/toqlite/vendorattribute
    [HttpGet]
    [Route("vendorattribute")]
    public async Task<JsonResult> GetVendorAttribute()
    {
        AdminTempProcedure adminProc = new AdminTempProcedure()
        {
            AttributeType = @"Vendor"
        };

        var result = await _adminRepo.Op_01(adminProc);
        return BaseResult.JsonResult(result);
    }

    //TODO - CENTRALIZE; GET THIS OUT OF THIS CONTROLLER
    //GET api/toqlite/section-attribute
    [HttpGet]
    [Route("section-attribute")]
    public async Task<JsonResult> GetSectionAttribute()
    {
        AdminTempProcedure adminProc = new AdminTempProcedure()
        {
            AttributeType = @"Section"
        };

        var result = await _adminRepo.Op_01(adminProc);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/deliverable/activity
    //Requires Deliverable (This is actually DeliverableID)
    [HttpPost]
    [Route("deliverable/activity")]
    public async Task<JsonResult> GetStandardActivities(TOQLiteProcedure model)
    {
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    #region Relocate to ER Endpoints

    //PUT api/toqlite/deliverable
    //Requires DeliverableName
    [HttpPut]
    [Route("deliverable")]
    public async Task<JsonResult> AddStandardDeliverable(TOQLiteProcedure model)
    {
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/deliverable
    //Requires Deliverable (This is actually DeliverableID)
    [HttpDelete]
    [Route("deliverable")]
    public async Task<OkObjectResult> DeleteStandardDeliverable(TOQLiteProcedure model)
    {
        var result = await _repository.Op_26(model);
        return new OkObjectResult(string.Format(@"Deliverable {0} was successfully deleted", model.Deliverable));
    }

    //PUT api/toqlite/deliverable/activity
    //Requires Activity and Deliverable (This is actually DeliverableID)
    [HttpPut]
    [Route("deliverable/activity")]
    public async Task<JsonResult> AddStandardDeliverableActivity(TOQLiteProcedure model)
    {
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/deliverable/activity
    //Requires ActivityID
    [HttpDelete]
    [Route("deliverable/activity")]
    public async Task<OkObjectResult> DeleteStandardDeliverableActivity(TOQLiteProcedure model)
    {
        var result = await _repository.Op_34(model);
        return new OkObjectResult(string.Format(@"Standard Deliverable Activity {0} was successfully deleted", model.ActivityID));
    }

    //PATCH api/toqlite/deliverable/activity
    //If SortUpdate = true, requires SortOrder
    //Else, requires ActivityID, Activity, ActivityHours
    [HttpPatch]
    [Route("deliverable/activity")]
    public async Task<OkObjectResult> EditStandardDeliverableActivity(TOQLiteProcedure model)
    {
        var result = await _repository.Op_27(model);
        return new OkObjectResult(string.Format(@"Activity {0} was successfully updated", model.ActivityID));
    }

    //GET api/toqlite/blendedrate
    [HttpGet]
    [Route("blendedrate")]
    public async Task<JsonResult> GetBlendedRate()
    {
        var result = await _repository.Op_28();
        return BaseResult.JsonResult(result);
    }

    //PATCH api/toqlite/blendedrate
    //Requires  BlendedRate (float)
    [HttpPatch]
    [Route("blendedrate")]
    public async Task<OkObjectResult> EditBlendedRate(TOQLiteProcedure model)
    {
        var result = await _repository.Op_29(model);
        return new OkObjectResult(string.Format(@"Blended Rate was successfully updated"));
    }

    //GET api/toqlite/outage
    [HttpGet]
    [Route("outage")]
    public async Task<JsonResult> GetOutages()
    {
        var result = await _repository.Op_30();
        return BaseResult.JsonResult(result);
    }

    //PUT api/toqlite/toq
    //Takes VendorShort and 
    [HttpPut]
    [Route("toq")]

    public async Task<JsonResult> AddTOQ([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_35(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/deliverable/activity
    //Requires VendorShort and VendorTOQID
    [HttpDelete]
    [Route("toq")]
    public async Task<OkObjectResult> DeleteTOQ(TOQLiteProcedure model)
    {
        var result = await _repository.Op_36(model);
        return new OkObjectResult(string.Format(@"Vendor TOQ ID {0} was successfully deleted", model.VendorTOQID));
    }

    //POST api/toqlite/outage/project
    //Takes Outage
    [HttpPost]
    [Route("outage/project")]

    public async Task<JsonResult> GetOutageProjects([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_37(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/toqlite/outage/project
    //Requires Outage and ProjectNo
    [HttpPut]
    [Route("outage/project")]

    public async Task<JsonResult> AddOutageProject([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_38(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/outage/project
    //Requires Outage and ProjectID
    [HttpDelete]
    [Route("outage/project")]

    public async Task<OkObjectResult> DeleteOutageProject([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_39(model);
        return new OkObjectResult(string.Format(@"Project {0} was successfully delinked from Outage {1}", model.ProjectNo, model.Outage));
    }

    #endregion

    //POST api/toqlite/vendor/deliverable/check
    //Requires TOQLiteID
    [HttpPost]
    [Route("vendor/deliverable/check")]
    public async Task<JsonResult> VendorDeliverableCheck(TOQLiteProcedure model)
    {
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/budget/report
    //Department is optional
    [HttpPost]
    [Route("budget/report")]
    public async Task<JsonResult> BudgetReport(TOQLiteProcedure model)
    {
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/vendor/deliverable
    //Takes VendorDeliverableID int argument
    [HttpDelete]
    [Route("vendor/deliverable")]

    public async Task<OkObjectResult> RemoveVendorDeliverable([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_41(model);
        return new OkObjectResult(string.Format(@"Vendor Deliverable {0} was successfully removed", model.VendorDeliverableID));
    }

    //POST api/toqlite/email
    [HttpPost]
    [Route("email")]
    public async Task<JsonResult> GetVendorEmail([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_42(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/toqlite/admin/qualification
    [HttpGet]
    [Route("admin/qualification")]
    public async Task<JsonResult> GetQualification()
    {
        var result = await _repository.Op_43();
        return BaseResult.JsonResult(result);
    }

    //PUT api/toqlite/admin/qualification
    [HttpPut]
    [Route("admin/qualification")]
    public async Task<JsonResult> AddQualification([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_44(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/toqlite/admin/qualification
    [HttpDelete]
    [Route("admin/qualification")]
    public async Task<JsonResult> DeleteQualification([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_45(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/qualification
    [HttpPost]
    [Route("qualification")]
    public async Task<JsonResult> Qualification([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/toqlite/qualification
    [HttpPatch]
    [Route("qualification")]
    public async Task<JsonResult> UpdateQualification([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_47(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/check-er
    [HttpPost]
    [Route("check-er")]
    public async Task<JsonResult> CheckER([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_48(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/toqlite/er/search-verify
    //Takes ER string as an argument
    [HttpPost]
    [Route("er/search-verify")]
    public async Task<JsonResult> SearchERVerify([FromBody] TOQLiteProcedure model)
    {
        var result = await _repository.Op_49(model);
        return BaseResult.JsonResult(result);
    }

}