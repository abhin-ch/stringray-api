using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;

public interface ITOQHelperFunctions
{
    Task<UserRole> GetUserRole(string employeeID);
    TOQResult CountHourClassV(TOQResult result);
    Task<bool> SendEmail(Procedure model);
    Task SubupEmails(Procedure model, TOQResult result);
    Task StatusUpdateEmails(Procedure model, TOQResult result);
    Task VCQuestionEmail(Procedure model);
    Task VCAnswerEmail(Procedure model);
    Task VCDateExtensionEmail(Procedure model);
    Task OEQuestionEmail(Procedure model);
    Task OEAnswerEmail(Procedure model);
}

public class TOQHelperFunctions : ITOQHelperFunctions
{
    readonly IRepositoryL<Procedure, TOQResult> _repository;
    readonly IHttpContextAccessor _httpContextAccessor;
    readonly IBackgroundTaskQueue _taskQueue;
    readonly ITOQSingletonService _singletonService;
    public TOQHelperFunctions(IRepositoryL<Procedure, TOQResult> repository, IBackgroundTaskQueue taskQueue,
    IHttpContextAccessor httpContextAccessor, ITOQSingletonService singletonService)
    {
        _httpContextAccessor = httpContextAccessor;
        _repository = repository;
        _taskQueue = taskQueue;
        _singletonService = singletonService;
    }

    public async Task<bool> SendEmail(Procedure model)
    {
        User? originalUser = (User)_httpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"];
        bool impersonating = _httpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS");

        await _singletonService.SendEmail(model, originalUser, impersonating);

        return true;
    }

    public async Task OEAnswerEmail(Procedure model)
    {
        Procedure emailModel = new Procedure();
        emailModel.Value1 = model.Value1;
        emailModel.Value2 = "ANSR";
        emailModel.Value6 = model.Value2;
        await SendEmail(emailModel);
    }

    public async Task OEQuestionEmail(Procedure model)
    {
        //Send question email
        Procedure emailModel = new Procedure();
        emailModel.Value1 = model.Value1;
        emailModel.Value2 = "QUES";
        emailModel.Value6 = model.Value7;
        await SendEmail(emailModel);
    }
    public async Task VCDateExtensionEmail(Procedure model)
    {
        Procedure emailModel = new Procedure();
        emailModel.Value1 = model.Value1;
        emailModel.Value2 = "QUES";
        emailModel.Value6 = model.Value4;
        await SendEmail(emailModel);
    }

    public async Task VCAnswerEmail(Procedure model)
    {
        Procedure emailModel = new Procedure();
        emailModel.Value1 = model.Value1;
        emailModel.Value2 = "ANSR";
        emailModel.Value6 = model.Value2;
        await SendEmail(emailModel);
    }

    public async Task VCQuestionEmail(Procedure model)
    {
        //Send question email
        Procedure emailModel = new Procedure();
        emailModel.Value1 = model.Value1;
        emailModel.Value2 = "QUES";
        emailModel.Value6 = model.Value7;
        await SendEmail(emailModel);
    }

    public async Task StatusUpdateEmails(Procedure model, TOQResult result)
    {
        //make sure not to reuse variables--will get overwritten and cause bugs

        //send email every status update
        Procedure emailModel = new Procedure();
        emailModel.Value1 = model.Value1;
        emailModel.Value2 = model.Value2;
        await SendEmail(emailModel);


        //Send additional emails on approved and complete
        if (model.Value2.Equals("ACC") || model.Value2.Equals("ACCF") || model.Value2.Equals("FULLR"))
        {
            Procedure completeEmailModel = new Procedure();
            completeEmailModel.Value1 = model.Value1;

            //if rev is 0 and is not child and is not fullr, send awarded email
            completeEmailModel.SubOp = 9;
            if (!model.Value2.Equals("FULLR") && DataParser.GetValueFromData<bool>((await _repository.Op_26(completeEmailModel)).Data1, "sendAward"))
            {
                completeEmailModel.Value2 = "AWARD";
                await SendEmail(completeEmailModel);
            }

            //if not emerg, and not routed from ODU or APCOR, and non awarded vendors exist, send non awarded email
            Procedure nonawEmailModel = new Procedure();
            nonawEmailModel.Value1 = model.Value1;

            nonawEmailModel.SubOp = 10;
            if (DataParser.GetValueFromData<bool>((await _repository.Op_26(nonawEmailModel)).Data1, "sendNONAW"))
            {
                nonawEmailModel.Value2 = "NONAW";
                await SendEmail(nonawEmailModel);
            }

            //if not emerg send deliv
            Procedure delivEmailModel = new Procedure();
            delivEmailModel.Value1 = model.Value1;
            delivEmailModel.SubOp = 8;
            if (!DataParser.GetValueFromData<bool>((await _repository.Op_26(delivEmailModel)).Data1, "isEmergent"))
            {
                delivEmailModel.Value2 = "DELIV";
                await SendEmail(delivEmailModel);

            }
        }
        //AVS check--send to deleted vendors not notified
        if (model.Value2.Equals("AVS"))
        {
            //get deleted vendors not notified, if it's not first time at AVS
            Procedure vendorModel = new Procedure();
            vendorModel.SubOp = 6;
            vendorModel.Value1 = model.Value1;
            var removedVendorsResult = await _repository.Op_26(vendorModel);


            if (removedVendorsResult.Data1.Any())
            {
                vendorModel.SubOp = 11;
                //clause to not send if this is the first time at AVS
                if (DataParser.GetValueFromData<int>((await _repository.Op_26(vendorModel)).Data1, "AVSCount") > 1)
                {
                    //send notification email to them "REMOV" op_26
                    vendorModel.Value2 = "REMOV";
                    await SendEmail(vendorModel);
                }



                //update list saying notified
                //also update this when not sending email--vendors don't need to be notified if never made it to AVS
                vendorModel.SubOp = 7;
                await _repository.Op_26(vendorModel);
            }
        }

        //Check if it says missing in MPL
        string? returnMessage = DataParser.GetValueFromData<string>(result.Data1, "ReturnMessage");
        if (returnMessage != null && returnMessage.Contains("missing in MPL"))
        {
            //send project missing in MPL email
            Procedure mplEmailModel = new Procedure();
            mplEmailModel.Value1 = model.Value1;
            mplEmailModel.Value2 = "MPL";
            await SendEmail(mplEmailModel);

        }
    }

    public async Task SubupEmails(Procedure model, TOQResult result)
    {
        //Submission update email
        Procedure emailModel = new Procedure();
        emailModel.Value2 = "SUBUP";
        emailModel.Value6 = model.Value1;
        await SendEmail(emailModel);

        var vssCode = DataParser.GetValueFromData<string>(result.Data1, "VSSCode");
        if (vssCode != null && vssCode.Equals("CO"))
        {
            Procedure vssModel = new Procedure();
            vssModel.Value6 = model.Value1;
            vssModel.Value2 = "AEBSP";
            await SendEmail(vssModel);

        }
    }

    public async Task<UserRole> GetUserRole(string employeeID)
    {
        var roleResult = await _repository.Op_22(new Procedure { EmployeeID = employeeID, SubOp = 2 });
        var roles = DataParser.GetListFromData(roleResult.Data1, "BPRole");

        var userrole = new UserRole
        {
            BPRoles = DataParser.GetListFromData(roleResult.Data1, "BPRole"),
            IsSysAdmin = DataParser.GetValueFromData<bool>(roleResult.Data1, "IsSysAdmin"),
            IsTOQAdmin = DataParser.GetValueFromData<bool>(roleResult.Data1, "IsTOQAdmin"),
            IsVendor = DataParser.GetValueFromData<bool>(roleResult.Data1, "IsVendor")
        };

        return userrole;
    }

    public TOQResult CountHourClassV(TOQResult result)
    {
        if (result?.Data1 != null && result?.Data2 != null)
        {
            //initialize temp dictionary
            Dictionary<int, decimal> totalHour = new Dictionary<int, decimal>();
            for (int i = 0; i < result.Data1.Count; i++)
            {
                totalHour[i] = 0;
            }
            //map total quantities
            foreach (Dictionary<string, object> dict2 in result.Data2)
            {
                int index = int.Parse((string)dict2["WBSValue"]) - 1;
                if (!dict2["EstHour"].Equals(""))//If it's not null 
                {
                    totalHour[index] += (decimal)(dict2["EstHour"]);
                }
            }
            //add row to result
            foreach (Dictionary<string, object> dict1 in result.Data1)
            {
                int index = int.Parse((string)dict1["Value"]) - 1;
                dict1.Add("EstHour", totalHour[index].ToString());
            }
        }
        return result;
    }
}