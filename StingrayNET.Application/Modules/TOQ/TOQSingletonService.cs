using Microsoft.Extensions.DependencyInjection;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.Infrastructure.Services.Azure;

public interface ITOQSingletonService
{
    public Task SendEmail(Procedure model, User originalUser, bool impersonating);

}

public class TOQSingletonService : ITOQSingletonService
{
    readonly IServiceScopeFactory _serviceScopeFactory;
    readonly IBaseEmailService _baseEmailService;
    public TOQSingletonService(IServiceScopeFactory serviceScopeFactory, IBaseEmailService baseEmailService)
    {
        _serviceScopeFactory = serviceScopeFactory;
        _baseEmailService = baseEmailService;
    }

    public async Task SendEmail(Procedure model, User originalUser, bool impersonating)
    {
        await _baseEmailService.SendEmail((token => BuildEmail(model)), originalUser, impersonating);
    }

    //make function sendemail that takes the task 'buildemail'. It passes a function buildemail2 into the query, 
    //which is just a function that creates the scope and then executes buildemail, build from there
    private async Task<QuickEmailTemplate> BuildEmail(Procedure model)
    {
        //scoped services need new scope created, since this is being used in singleton (after original scope closure)
        using var scope = _serviceScopeFactory.CreateScope();
        var _repository = scope.ServiceProvider.GetRequiredService<IRepositoryL<Procedure, TOQResult>>();

        //All:
        //Value1 -> UniqueID (TOQ_Main)
        // --Value2 -> Next Status Code / Made Up Status Code

        // --Question from Vendor Correspondence:
        // 	--Value6 -> QuestionID (TOQ_VendorCorrespondence)

        // 	--Vendor Submission Update
        // 	--Value6 -> UniqueID (TOQ_VendorAssigned / TOQ_VendorStatusLog)
        // 	--Value7 -> Submission Type

        model.SubOp = 1;
        Task<TOQResult> toDataTask = _repository.Op_26(model);
        model.SubOp = 2;
        Task<TOQResult> ccDataTask = _repository.Op_26(model);
        model.SubOp = 3;
        Task<TOQResult> miscDataTask = _repository.Op_26(model);
        model.SubOp = 4;
        Task<TOQResult> bccDataTask = _repository.Op_26(model);
        model.SubOp = 5;
        Task<TOQResult> delivDataTask = _repository.Op_26(model);

        TOQResult.EmailResult email = new TOQResult.EmailResult();


        //Deal with recipients
        List<object> toData = (await toDataTask).Data1;
        email.To = DataParser.GetListFromData(toData, "EmailTo");
        var RecipientList = DataParser.GetListFromData(toData, "Recipient");
        var Recipient = "";

        for (int i = 0; i < RecipientList.Count; i++)
        {
            if (i == 0)
            {
                Recipient += RecipientList[0];
            }
            else
            {
                Recipient += ", " + RecipientList[i];
            }

        }

        //Deal with CC items
        List<object> ccData = (await ccDataTask).Data1;
        email.CC = DataParser.GetListFromData(ccData, "EmailCC");


        //Deal with BCC items
        List<object> bccData = (await bccDataTask).Data1;

        email.BCC = DataParser.GetListFromData(bccData, "EmailBCC");


        //Deal with misc data items
        List<object> miscData = (await miscDataTask).Data1;

        email.EmailBody = DataParser.GetValueFromData<string>(miscData, "EmailBody");
        email.EmailSubject = DataParser.GetValueFromData<string>(miscData, "EmailSubject");

        //Get variables from data, not always used, sometimes null
        var EmailType = DataParser.GetValueFromData<string>(miscData, "EmailType");
        var DatabaseStatus = DataParser.GetValueFromData<string>(miscData, "DatabaseStatus");
        var ID = DataParser.GetValueFromData<string>(miscData, "ID");
        var TOQID = DataParser.GetValueFromData<string>(miscData, "TOQID");
        var NewStatus = DataParser.GetValueFromData<string>(miscData, "NewStatus");
        var TaskOrderTitle = DataParser.GetValueFromData<string>(miscData, "TaskOrderTitle");
        var TDSNum = DataParser.GetValueFromData<string>(miscData, "TDSNum");
        var ProjectNum = DataParser.GetValueFromData<string>(miscData, "ProjectNum");
        var OE = DataParser.GetValueFromData<string>(miscData, "OE");
        var SM = DataParser.GetValueFromData<string>(miscData, "SM");
        var DM = DataParser.GetValueFromData<string>(miscData, "DM");
        var Rev = DataParser.GetValueFromData<string>(miscData, "Rev");
        var Comment = DataParser.GetValueFromData<string>(miscData, "Comment");
        var Vendor = DataParser.GetValueFromData<string>(miscData, "Vendor");
        var Type = DataParser.GetValueFromData<string>(miscData, "Type");
        var SubmissionStatus = DataParser.GetValueFromData<string>(miscData, "SubmissionStatus");
        var StatusUpdateComment = DataParser.GetValueFromData<string>(miscData, "StatusUpdateComment");
        var QuestionSubject = DataParser.GetValueFromData<string>(miscData, "QuestionSubject");
        var QuestionDetails = DataParser.GetValueFromData<string>(miscData, "QuestionDetails");
        var AdditionalQuestionDetails = DataParser.GetValueFromData<string>(miscData, "AdditionalQuestionDetails");
        var AwardedTotalCost = DataParser.GetValueFromData<string>(miscData, "AwardedTotalCost");
        var AwardedVendor = DataParser.GetValueFromData<string>(miscData, "AwardedVendor");
        var AwardedTOQNumber = DataParser.GetValueFromData<string>(miscData, "AwardedTOQNumber");
        var AwardedRev = DataParser.GetValueFromData<string>(miscData, "AwardedRev");
        var AwardedDate = DataParser.GetValueFromData<string>(miscData, "AwardedDate");
        var Scope = DataParser.GetValueFromData<string>(miscData, "Scope");
        var PartialRelease = DataParser.GetValueFromData<string>(miscData, "PartialRelease");
        var IsChild = DataParser.GetValueFromData<string>(miscData, "IsChild");
        var RoutedFromStatus = DataParser.GetValueFromData<string>(miscData, "RoutedFromStatus");
        var VendorClarificationDate = DataParser.GetValueFromData<string>(miscData, "VendorClarificationDate");
        var VendorSubmissionDate = DataParser.GetValueFromData<string>(miscData, "VendorSubmissionDate");
        var Partial = DataParser.GetValueFromData<string>(miscData, "Partial");
        string ApprovedLevel = Partial.Equals("Yes") ? "Partially Approved" : model.Value2.Equals("FULLR") ? "Fully Released" : "Fully Approved";
        var DatabaseStatusID = DataParser.GetValueFromData<string>(miscData, "DatabaseStatusID");
        var SourceID = DataParser.GetValueFromData<string>(miscData, "SourceID");
        var EmergentTotalRow = DataParser.GetValueFromData<string>(miscData, "EmergentTotalRow");
        var VOE = DataParser.GetValueFromData<string>(miscData, "VOE");
        var VOEMessage = DataParser.GetValueFromData<string>(miscData, "VOEMessage");
        var Answer = DataParser.GetValueFromData<string>(miscData, "Answer");










        var keyValuePairs = new Dictionary<string, string>();
        switch (EmailType)
        {
            case "Status Change General":
                keyValuePairs.Add("[PreviousStatus]", DatabaseStatus);
                keyValuePairs.Add("[Status]", NewStatus);
                break;
            case "Notification General":
                keyValuePairs.Add("[PreviousStatus]", DatabaseStatus);
                keyValuePairs.Add("[Status]", NewStatus);
                break;
            case "Submission Update General":
                keyValuePairs.Add("[Status]", DatabaseStatus);
                keyValuePairs.Add("[StatusUpdateComment]", StatusUpdateComment);
                break;
            case "Non Awarded General":
                keyValuePairs.Add("[Status]", DatabaseStatus);
                //keyValuePairs.Add("[ReasonNotSelected]", ReasonNotSelected);
                break;
            case "Awarded General":
            case "Awarded Late Start 1":
            case "Awarded Late Start 2":
                keyValuePairs.Add("[Status]", DatabaseStatus);
                keyValuePairs.Add("[AwardedRev]", AwardedRev);
                keyValuePairs.Add("[AwardedDate]", AwardedDate);
                keyValuePairs.Add("[AwardedVendor]", AwardedVendor);
                keyValuePairs.Add("[AwardedTOQNumber]", AwardedTOQNumber);
                keyValuePairs.Add("[Scope]", Scope);
                keyValuePairs.Add("[TOQorEWR]", (Type != null && Type.Equals("Emergent")) ? ("Emergent Work ID: " + ID) : "TOQ");
                break;
            case "Question General":
                keyValuePairs.Add("[Status]", DatabaseStatus);
                keyValuePairs.Add("[QuestionSubject]", QuestionSubject);
                keyValuePairs.Add("[QuestionDetails]", QuestionDetails);
                keyValuePairs.Add("[AdditionalQuestionDetails]", AdditionalQuestionDetails);
                keyValuePairs.Add("[Answer]", Answer);
                keyValuePairs.Add("[VOE]", VOE);
                keyValuePairs.Add("[VOEMessage]", VOEMessage);
                break;
            case "Deliverable Accounts General":
            case "Deliverable Accounts Late Start 1":
            case "Deliverable Accounts Late Start 2":
                keyValuePairs.Add("[EmailType]", EmailType);
                keyValuePairs.Add("[AwardedTotalCost]", AwardedTotalCost);
                keyValuePairs.Add("[Rev]", Rev);
                keyValuePairs.Add("[AwardedVendor]", AwardedVendor);
                keyValuePairs.Add("[AwardedTOQNumber]", AwardedTOQNumber);
                keyValuePairs.Add("[PartialRelease]", PartialRelease);
                keyValuePairs.Add("[Scope]", Scope);
                break;
            case "Additional Partial General":
                keyValuePairs.Add("[Status]", DatabaseStatus);
                keyValuePairs.Add("[PartialRelease]", PartialRelease);
                break;
            case "Vendor Selected General":
                keyValuePairs.Add("[Status]", DatabaseStatus);
                keyValuePairs.Add("[VendorClarificationDate]", VendorClarificationDate);
                keyValuePairs.Add("[VendorSubmissionDate]", VendorSubmissionDate);
                break;
            default:
                keyValuePairs.Add("[Status]", DatabaseStatus);
                break;
        }

        keyValuePairs.Add("[ID]", ID);
        keyValuePairs.Add("[TOQID]", TOQID);
        keyValuePairs.Add("[TDSNum]", TDSNum);
        keyValuePairs.Add("[ProjectNum]", ProjectNum);
        keyValuePairs.Add("[OE]", OE);
        keyValuePairs.Add("[SM]", SM);
        keyValuePairs.Add("[DM]", DM);
        keyValuePairs.Add("[Comment]", Comment);
        keyValuePairs.Add("[TaskOrderTitle]", TaskOrderTitle);
        keyValuePairs.Add("[Recipient]", Recipient);
        keyValuePairs.Add("[Vendor]", Vendor);
        keyValuePairs.Add("[SubmissionStatus]", SubmissionStatus);
        keyValuePairs.Add("[RoutedFromStatus]", RoutedFromStatus);
        keyValuePairs.Add("[Partial]", Partial);
        keyValuePairs.Add("[ApprovedLevel]", ApprovedLevel);
        keyValuePairs.Add("[SourceID]", SourceID);
        keyValuePairs.Add("[Type]", Type);
        keyValuePairs.Add("[IsChild]", IsChild.Equals("0") ? "No" : "Yes");
        keyValuePairs.Add("[EmergentTotalRow]", EmergentTotalRow);

        //hyperlink dependent on environment
        string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        string DeepLink = "https://stingray.brucepower.com/toq";

        if (env == null || env.Equals("Production", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingray.brucepower.com/TOQ?TOQ={SourceID}";
        }
        else if (env.Equals("QA", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingrayqafe.azurewebsites.net/TOQ?TOQ={SourceID}";
        }
        else if (env.Equals("Development", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingraydevfe.azurewebsites.net/TOQ?TOQ={SourceID}";
        }
        keyValuePairs.Add("[DeepLink]", DeepLink);

        //Work with deliv Data
        List<object> delivData = (await delivDataTask).Data1;

        if (model.Value2.Equals("DELIV"))
        {
            email.EmailBody += "<style>table{border-style: solid;border-width:1px;border-color: black;border-collapse: collapse;}</style><table cellpadding=5 cellspacing=0 border='1'><tr> <td bgcolor=#E6E6FA><b>Deliverable Title</b></td><td bgcolor=#E6E6FA><b>Total Hours</b></td><td bgcolor=#E6E6FA><b>Total Estimate</b></td>" + (Partial.Equals("Yes") ? "<td bgcolor=#E6E6FA><b>Partial Approval</b></td>" : "") + "<td bgcolor=#E6E6FA><b>Deliverable Start Date</b></td><td bgcolor=#E6E6FA><b>Deliverable End Date</b></td><td bgcolor=#E6E6FA><b>Deliverable Account</b></td><td bgcolor=#E6E6FA><b>Deliverable Code</b></td><td bgcolor=#E6E6FA><b>Current TOQ Commitment Date</b></td></tr>";

            for (int i = 0; i < delivData.Count; i++)
            {
                email.EmailBody += "<tr><td>[DeliverableTitle" + i.ToString() + "]</td><td>[TotalHours" + i.ToString() + "]</td><td>[TotalEstimate" + i.ToString() + "]</td>" + (Partial.Equals("Yes") ? ($"<td>[PartialApproval" + i.ToString() + "]</td>") : "") + "<td>[DeliverableStartDate" + i.ToString() + "]</td><td>[DeliverableEndDate" + i.ToString() + "]</td><td>[DeliverableAccount" + i.ToString() + "]</td><td>[DeliverableCode" + i.ToString() + "]</td><td>[CurrentTOQCommitmentDate" + i.ToString() + "]</td>";
                keyValuePairs.Add($"[DeliverableTitle{i}]", (((Dictionary<string, object>)(delivData[i]))["DeliverableTitle"]).Equals("") ? "" : (((Dictionary<string, object>)(delivData[i]))["DeliverableTitle"]).ToString());
                keyValuePairs.Add($"[TotalHours{i}]", (((Dictionary<string, object>)(delivData[i]))["TotalHour"]).Equals("") ? "" : ((decimal)(((Dictionary<string, object>)(delivData[i]))["TotalHour"])).ToString("0.00"));
                keyValuePairs.Add($"[TotalEstimate{i}]", (((Dictionary<string, object>)(delivData[i]))["TotalCost"]).Equals("") ? "" : ((decimal)(((Dictionary<string, object>)(delivData[i]))["TotalCost"])).ToString("0.00"));
                keyValuePairs.Add($"[DeliverableStartDate{i}]", (((Dictionary<string, object>)(delivData[i]))["DeliverableStartDate"]).Equals("") ? "" : ((DateTime)(((Dictionary<string, object>)(delivData[i]))["DeliverableStartDate"])).ToString("dd-MMM-yyyy"));
                keyValuePairs.Add($"[DeliverableEndDate{i}]", (((Dictionary<string, object>)(delivData[i]))["DeliverableEndDate"]).Equals("") ? "" : ((DateTime)(((Dictionary<string, object>)(delivData[i]))["DeliverableEndDate"])).ToString("dd-MMM-yyyy"));
                keyValuePairs.Add($"[DeliverableAccount{i}]", (((Dictionary<string, object>)(delivData[i]))["DeliverableAccount"]).Equals("") ? "" : ((int)(((Dictionary<string, object>)(delivData[i]))["DeliverableAccount"])).ToString());
                keyValuePairs.Add($"[DeliverableCode{i}]", (((Dictionary<string, object>)(delivData[i]))["DeliverableCode"]).Equals("") ? "" : (((Dictionary<string, object>)(delivData[i]))["DeliverableCode"]).ToString());
                keyValuePairs.Add($"[CurrentTOQCommitmentDate{i}]", (((Dictionary<string, object>)(delivData[i]))["CurrentTOQCommitmentDate"]).Equals("") ? "" : ((DateTime)(((Dictionary<string, object>)(delivData[i]))["CurrentTOQCommitmentDate"])).ToString("dd-MMM-yyyy"));
                if (Partial.Equals("Yes"))
                {//include partials column
                    keyValuePairs.Add($"[PartialApproval{i}]", (((Dictionary<string, object>)(delivData[i]))["DistributedPartial"]).Equals("") ? "" : ((decimal)(((Dictionary<string, object>)(delivData[i]))["DistributedPartial"])).ToString("0.00"));
                }
            }
            email.EmailBody += "</table><br/><table cellpadding= 5 cellspacing=0 border= 1><tr><th bgcolor=#E6E6FA>TMID</th><th bgcolor=#E6E6FA>Rev</th><th bgcolor=#E6E6FA>Title</th><th bgcolor=#E6E6FA>Awarded Vendor</th><th bgcolor=#E6E6FA>Awarded TOQ Number</th>"
            + (Partial.Equals("Yes") ? "<th bgcolor=#E6E6FA>Partial Release</th>" : "") + "<th bgcolor=#E6E6FA>Awarded Total Cost</th><th bgcolor=#E6E6FA>TOQ Type</th><th bgcolor=#E6E6FA>Scope Managed By</th></tr><tr><td>[ID]</td><td>[Rev]</td><td>[TaskOrderTitle]</td><td>[AwardedVendor]</td><td>[AwardedTOQNumber]</td>"
             + (Partial.Equals("Yes") ? "<td>$[PartialRelease]</td>" : "") + "<td>$[AwardedTotalCost]</td><td>[Type]</td><td>[Scope]</td></tr></table></table><br/></body></html>";
        }

        //Finally, populate email text with variables
        email.EmailBody = Template.Populate(email.EmailBody, keyValuePairs);
        email.EmailSubject = Template.Populate(email.EmailSubject, keyValuePairs);



        return new QuickEmailTemplate
        {
            toList = email.To,
            CCList = email.CC,
            BCCList = email.BCC,
            subject = email.EmailSubject,
            emailBody = email.EmailBody
        };
    }
}