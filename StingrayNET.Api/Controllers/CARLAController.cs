using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.CARLA;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Specifications.Request;
using System.Net;

namespace StingrayNET.Api.Controllers;

[ModuleRoute("api/[controller]", ModuleEnum.CARLA)]
public class CARLAController : BaseApiController
{
    private readonly IRepositoryXL<CARLAProcedure, CARLAResult> _repository;
    private readonly IEmailService _emailService;

    public CARLAController(IRepositoryXL<CARLAProcedure, CARLAResult> repository,
        IIdentityService identityService,
        IEmailService emailService) : base(identityService)
    {
        _repository = repository;
        _emailService = emailService;
    }

    //PATCH api/carla/reset-date
    [Route("reset-date")]
    [HttpPatch]
    public async Task<JsonResult> Op_1(string activityID, string fieldName)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        model.Value2 = fieldName;
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST /api/carla/csq-list
    [Route("csq-list")]
    [HttpPost]
    public async Task<JsonResult> Op_2([FromBody] CARLAProcedure model)
    {
        var csqList = await _repository.Op_02(model);
        return BaseResult.JsonResult(csqList);
    }


    //GET /api/carla/Planner-View
    [Route("planners-view")]
    [HttpGet]
    public async Task<JsonResult> Op_26()
    {
        var plannersView = await _repository.Op_26();
        return BaseResult.JsonResult(plannersView);
    }

    //POST api/carla/childactivities
    [Route("child-activities")]
    [HttpPost]
    public async Task<JsonResult> Op_06([FromBody] CARLAProcedure model)
    {
        // CARLAProcedure model = new CARLAProcedure();
        // model.Value1 = activityID;
        var activityList = await _repository.Op_06(model);
        return BaseResult.JsonResult(activityList);
    }


    //POST api/carla/child-activities-planner
    [Route("child-activities-planner")]
    [HttpPost]
    public async Task<JsonResult> Op_27([FromBody] CARLAProcedure model)
    {

        var activityList = await _repository.Op_27(model);
        return BaseResult.JsonResult(activityList);
    }


    //POST api/Carla/internalNotes
    [Route("internal-note")]
    [HttpPost]
    public async Task<JsonResult> Op_3([FromBody] CARLAProcedure model)
    {

        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var note = await _repository.Op_03(model);
        return BaseResult.JsonResult(note);
    }

    //PUT api/Carla/internalNote
    [Route("internal-note")]
    [HttpPut]
    public async Task<JsonResult> Op_4([FromBody] CARLAProcedure model)
    {
        model.Num1 = model.Value2.Length;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var note = await _repository.Op_04(model);
        return BaseResult.JsonResult(note);
    }

    //PATCH api/Carla/emailInit
    [Route("email-init")]
    [HttpPatch]
    public async Task<JsonResult> Op_5(string activityID)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/Carla/commitment-Review
    [Route("commitment-review")]
    [HttpGet]

    public async Task<JsonResult> Op_7()
    {
        var result = await _repository.Op_07();
        return BaseResult.JsonResult(result);
    }

    //GET api/Carla/commitmentReview/childActivities
    [Route("commitment-review/child-activities")]
    [HttpGet]
    public async Task<JsonResult> Op_06Review(string activityID)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/Carla/status
    [Route("status")]
    [HttpPost]
    public async Task<JsonResult> Op_8(string activityID, [FromBody] CARLAProcedure model)
    {
        model.Value1 = activityID;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }
#nullable disable
    // POST /api/email/download
    [HttpPost]
    [Route("email/schedule-update")]
    public async Task<ActionResult> DownloadEmail([FromBody] CARLAProcedure model)
    {
        try
        {
            var user = await _identityService.GetUser(HttpContext);
            model.EmployeeID = user.EmployeeID;

            try
            {
                if (model.Value2 != null) model.SubFragnetList = new ScheduleTable<SubFragnetList>(model.Value2);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }

            var result = await _repository.Op_12(model);

            var template = ScheduleUpdateEmail.GetEmailTemplate(result);
            var project = ScheduleUpdateEmail.GetProjectInfo(result);
            var activities = ScheduleUpdateEmail.GetActivities(result);



            var schedule = new ScheduleUpdateEmail(project, template, activities);

            var msg = schedule.CreateMsgTemplate(user.Email);
            if (msg != null)
                return await _emailService.Download(msg, $"{model.Value1}-ScheduleUpdate");
            else
                return BadRequest("Msg template is empty");
        }
        catch (Exception ex)
        {
            return BadRequest(ex.Message);
        }
    }

#nullable enable
    //POST api/Carla/changeLog
    [Route("change-log")]
    [HttpPost]
    public async Task<JsonResult> Op_9([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/Carla/commitmentReviewAll
    [Route("commitment-review-all")]
    [HttpGet]
    public async Task<JsonResult> Op_10()
    {
        var result = await _repository.Op_10();
        return BaseResult.JsonResult(result);
    }

    //PUT api/Carla/category
    [Route("category")]
    [HttpPut]
    public async Task<JsonResult> Op_11([FromBody] CARLAProcedure model)
    {

        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/Carla/schedule-change
    [Route("schedule-change")]
    [HttpPost]
    public async Task<JsonResult> Op_13([FromBody] CARLAProcedure model)
    {
        var result = new CARLAResult();
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/Carla/schedule-change-temp
    [Route("schedule-change-temp")]
    [HttpPost]
    public async Task<JsonResult> Op_14([FromBody] CARLAProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/Carla/update-required
    [Route("update-required")]
    [HttpPost]
    public async Task<JsonResult> Op_19([FromBody] CARLAProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/Carla/clear-Status
    [Route("clear-status")]
    [HttpPatch]
    public async Task<JsonResult> Op_20(string activityID)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/Carla/activity-scope-detail
    [Route("activity-scope-details")]
    [HttpDelete]
    public async Task<JsonResult> Op_21(string activityID, string faDetailID)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        model.Value2 = faDetailID;
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/carla/activity-scope-detail
    [Route("activity-scope-detail")]
    [HttpPost]
    public async Task<JsonResult> GetActivityScopeDetails([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/carla/activity-scope-detail
    [Route("activity-scope-details")]
    [HttpPost]
    public async Task<JsonResult> Op_22(string activityID, string type, string number)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        model.Value2 = type;
        model.Value3 = number;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/carla/submission-to-planners
    [Route("submission-to-planners")]
    [HttpPost]
    [ProducesResponseType(typeof(Return<CARLAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_25([FromBody] CARLAProcedure model)
    {


        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/CARLA/activity-scope-detail
    [Route("activity-scope-details")]
    [HttpPut]
    public async Task<JsonResult> Op_17(string activityID, [FromBody] RequestBody body)
    {
        CARLAProcedure model = new CARLAProcedure();
        model.Value1 = activityID;
        model.Value2 = body.GetValue<string>("Value");
        model.Value3 = body.GetValue<string>("FADetailID");
        model.IsTrue1 = body.GetValue<bool>("Field");
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/carla/csq-summary
    [Route("csq-summary")]
    [HttpPost]
    public async Task<JsonResult> Op_24([FromBody] CARLAProcedure model)
    {
        // CARLAProcedure model = new CARLAProcedure();
        // model.Value1 = ActivityID;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }


    //Put api/carla/sendtoplanner
    [HttpPut]
    [Route("sendtoplanner")]
    public async Task<JsonResult> SendtoPlanner([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);

    }

    //Patch api/add-status-from-planner
    [HttpPatch]
    [Route("plannerstatus")]
    public async Task<JsonResult> updatestatus([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/plannerstatus
    [HttpPost]
    [Route("plannerstatus")]
    public async Task<JsonResult> getstatus([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/plannerstatuscurrent
    [HttpPost]
    [Route("plannerstatuscurrent")]
    public async Task<JsonResult> getstatuscurrent([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }

    //POST Api/Planner-email
    [Route("planner-email")]
    [HttpPost]
    public async Task<JsonResult> PlannerIssueEmail([FromBody] CARLAProcedure model)
    {

        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/child-activities-temp
    [Route("child-activities-temp")]
    [HttpPost]
    public async Task<JsonResult> Op_33([FromBody] CARLAProcedure model)
    {

        var activityList = await _repository.Op_33(model);
        return BaseResult.JsonResult(activityList);
    }
    //POST api/carla/actualized
    [Route("actualized")]
    [HttpPost]
    public async Task<JsonResult> Op_34([FromBody] CARLAProcedure model)
    {

        var activityList = await _repository.Op_34(model);
        return BaseResult.JsonResult(activityList);
    }
    //POST api/carla/NR-change
    [Route("NR-change")]
    [HttpPost]
    public async Task<JsonResult> Op_35([FromBody] CARLAProcedure model)
    {

        var activityList = await _repository.Op_35(model);
        return BaseResult.JsonResult(activityList);
    }
    //GET api/carla/csqdropdown
    [Route("csqdropdown")]
    [HttpGet]
    public async Task<JsonResult> Op_36()
    {

        var result = await _repository.Op_36();
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/child-activities-olddata
    [Route("child-activities-olddata")]
    [HttpPost]
    public async Task<JsonResult> Op_37([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_37(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/schedule-change-temp-Icon
    [Route("schedule-change-temp-icon")]
    [HttpPost]
    public async Task<JsonResult> Op_38([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_38(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/carla/searchwo
    [Route("searchwo")]
    [HttpPost]
    public async Task<JsonResult> Op_39([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_39(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/searchwoItem
    [Route("searchwoItem")]
    [HttpPost]
    public async Task<JsonResult> Op_40([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_40(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/searchETDBTDS
    [Route("searchETDBTDS")]
    [HttpPost]
    public async Task<JsonResult> Op_41([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_41(model);
        return BaseResult.JsonResult(result);


    }
    //POST api/carla/searchService
    [Route("searchService")]
    [HttpPost]
    public async Task<JsonResult> Op_42([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_42(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/TDS
    [Route("tds")]
    [HttpPost]
    public async Task<JsonResult> Op_43([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_43(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/wo
    [Route("wo")]
    [HttpPost]
    public async Task<JsonResult> Op_44([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_44(model);
        return BaseResult.JsonResult(result);
    }
    //POST api/carla/servicepr
    [Route("servicepr")]
    [HttpPost]
    public async Task<JsonResult> Op_45([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_45(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/carla/scopedetails
    [Route("scopedetails")]
    [HttpPost]
    public async Task<JsonResult> Op_46([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_46(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/carla/item
    [Route("item")]
    [HttpPost]
    public async Task<JsonResult> Op_47([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_47(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/carla/item
    [Route("latestComment")]
    [HttpPatch]
    public async Task<JsonResult> Op_48([FromBody] CARLAProcedure model)
    {
        var result = await _repository.Op_48(model);
        return BaseResult.JsonResult(result);
    }


}
