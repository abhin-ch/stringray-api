using Microsoft.Extensions.DependencyInjection;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.Infrastructure.Services.Azure;

public interface IPCCSingletonService
{
    public Task SendEmail(PCCEmailModel model, User originalUser, bool impersonating);


}

public class PCCSingletonService : IPCCSingletonService
{
    readonly ISingletonEmailSender _singletonEmailSender;
    readonly IServiceScopeFactory _serviceScopeFactory;
    readonly IBackgroundTaskQueue _taskQueue;
    readonly IBaseEmailService _baseEmailService;
    public PCCSingletonService(IServiceScopeFactory serviceScopeFactory, IBaseEmailService baseEmailService)
    {
        _serviceScopeFactory = serviceScopeFactory;
        _baseEmailService = baseEmailService;
    }


    public async Task SendEmail(PCCEmailModel model, User originalUser, bool impersonating)
    {
        await _baseEmailService.SendEmail((token => BuildEmail(model)), originalUser, impersonating);
    }

    private async Task<QuickEmailTemplate> BuildEmail(PCCEmailModel model)
    {
        //scoped services need new scope created, since this is being used in singleton (after original scope closure)
        using var scope = _serviceScopeFactory.CreateScope();
        var _repository = scope.ServiceProvider.GetRequiredService<IRepositoryXL<PCCProcedure, PCCResult>>();

        var pccModel = new PCCProcedure
        {
            EmployeeID = model.EmployeeID,
            SubOp = 1,
            Value1 = model.Value1,
            Value2 = model.Value2,
            RecordType = model.RecordType
        };
        var result = await _repository.Op_31(pccModel);

        result.Email = new PCCResult.EmailResult();


        var StatusValue = DataParser.GetValueFromData<string>(result.Data3, "StatusValue");
        var Status = DataParser.GetValueFromData<string>(result.Data3, "Status");

        result.Email.EmailBody = DataParser.GetValueFromData<string>(result.Data3, "EmailBody");
        result.Email.EmailSubject = DataParser.GetValueFromData<string>(result.Data3, "EmailSubject");
        result.Email.To = DataParser.GetListFromData(result.Data1, "EmailTo");
        if (model.Value2 != null && model.Value2.Equals("BNPD"))
        {
            result.Email.To = new List<string>{
                "bnpdesdprojectbaseliningrequest@brucepower.com"
            };
        }

        result.Email.CC = DataParser.GetListFromData(result.Data2, "EmailCC");

        pccModel.SubOp = 2;
        var bccResult = await _repository.Op_31(pccModel);//restructure to await only when needed later
        result.Email.BCC = DataParser.GetListFromData(bccResult.Data1, "EmailBCC");

        var RecipientList = DataParser.GetListFromData(result.Data1, "Recipient");
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

        var keyValuePairs = new Dictionary<string, string>();

        var Workflow = DataParser.GetValueFromData<string>(result.Data3, "Workflow");
        var PreviousStatus = DataParser.GetValueFromData<string>(result.Data3, "PreviousStatus");
        var PreviousStatusValue = DataParser.GetValueFromData<string>(result.Data3, "PreviousStatusValue");
        var ID = DataParser.GetValueFromData<string>(result.Data3, "ID");
        var ProjNum = DataParser.GetValueFromData<string>(result.Data3, "ProjNum");
        var TaskOrderTitle = DataParser.GetValueFromData<string>(result.Data3, "TaskOrderTitle");
        var RequestFrom = DataParser.GetValueFromData<string>(result.Data3, "RequestFrom");
        var RecordTypeUniqueID = DataParser.GetValueFromData<string>(result.Data3, "RecordTypeUniqueID");

        var LSMessage = "";
        var SMAll = "";
        var VerifierAll = "";
        if (Workflow.Equals("PBRF"))
        {
            var Rev = DataParser.GetValueFromData<string>(result.Data3, "Rev");
            keyValuePairs.Add("[Rev]", Rev);
        }
        else if (Workflow.Equals("SDQ"))
        {
            var Rev = DataParser.GetValueFromData<string>(result.Data3, "Rev");
            keyValuePairs.Add("[Rev]", Rev);
        }
        else if (Workflow.Equals("DVN"))
        {

        }
        else
        {
            throw new NotImplementedException("Workflow " + Workflow + " not implemented");
        }

        keyValuePairs.Add("[Recipient]", Recipient);
        keyValuePairs.Add("[Status]", Status);
        keyValuePairs.Add("[Workflow]", Workflow);
        keyValuePairs.Add("[PreviousStatus]", PreviousStatus);
        keyValuePairs.Add("[ID]", ID);
        keyValuePairs.Add("[ProjNum]", ProjNum);
        keyValuePairs.Add("[TaskOrderTitle]", TaskOrderTitle);
        keyValuePairs.Add("[RequestFrom]", RequestFrom);
        keyValuePairs.Add("[RecordTypeUniqueID]", RecordTypeUniqueID);

        //hyperlink dependent on environment
        string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        string DeepLink = "https://stingray.brucepower.com/budgeting";
        if (env == null || env.Equals("Production", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingray.brucepower.com/Budgeting?{Workflow}={RecordTypeUniqueID}";
        }
        else if (env.Equals("QA", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingrayqafe.azurewebsites.net/Budgeting?{Workflow}={RecordTypeUniqueID}";
        }
        else if (env.Equals("Development", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingraydevfe.azurewebsites.net/Budgeting?{Workflow}={RecordTypeUniqueID}";
        }
        keyValuePairs.Add("[DeepLink]", DeepLink);

        //Add late start message conditionally
        if (PreviousStatusValue != null && (PreviousStatusValue.Equals("AOERC") || PreviousStatusValue.Equals("APCSC") || PreviousStatusValue.Equals("AOEFR")))
        {
            if (StatusValue.Equals("APRE"))
            {
                LSMessage = "Revised commitment dates and/or partial funding distribution and/or minor comments have been incorporated, if applicable";
            }
            else if (StatusValue.Equals("AFRE"))
            {
                LSMessage = "Revised commitment dates and/or minor comments have been incorporated, if applicable";
            }
        }
        keyValuePairs.Add("[LSMessage]", LSMessage);

        //Logic to generate sm lists on ASMA
        if (model.RecordType.Equals("SDQ") && StatusValue != null && StatusValue.Equals("ASMA"))
        {
            //op for getting SMs
            pccModel.SubOp = 3;
            var SMResult = await _repository.Op_31(pccModel);

            //for each row in returned SMs, generate text
            for (int i = 0; i < SMResult.Data1.Count; i++)
            {
                SMAll += "Manager: " + (((Dictionary<string, object>)(SMResult.Data1[i]))["Approver"]).ToString() +
                 "-- Discipline: " + (((Dictionary<string, object>)(SMResult.Data1[i]))["Discipline"]).ToString() +
                 " -- Approval Status: " + (((Dictionary<string, object>)(SMResult.Data1[i]))["Status"]).ToString() +
                 "<br>";
            }

        }
        keyValuePairs.Add("[SMAll]", SMAll);

        //Logic to geneate verifier lists on AVER
        if (model.RecordType.Equals("SDQ") && StatusValue != null && StatusValue.Equals("AVER"))
        {
            //op for getting Verifierss
            pccModel.SubOp = 4;
            var VerifierResult = await _repository.Op_31(pccModel);

            //for each row in returned verifiers, generate text
            for (int i = 0; i < VerifierResult.Data1.Count; i++)
            {
                VerifierAll += (((Dictionary<string, object>)(VerifierResult.Data1[i]))["ApprovalType"]).ToString() +
                 " -- " + (((Dictionary<string, object>)(VerifierResult.Data1[i]))["Approver"]).ToString() +
                 " -- Approval Status: " + (((Dictionary<string, object>)(VerifierResult.Data1[i]))["Status"]).ToString() +
                 "<br>";
            }
        }
        keyValuePairs.Add("[VerifierAll]", VerifierAll);

        result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);
        result.Email.EmailSubject = Template.Populate(result.Email.EmailSubject, keyValuePairs);

        return new QuickEmailTemplate
        {
            toList = result.Email.To,
            CCList = result.Email.CC,
            BCCList = result.Email.BCC,
            subject = result.Email.EmailSubject,
            emailBody = result.Email.EmailBody
        };
    }
}