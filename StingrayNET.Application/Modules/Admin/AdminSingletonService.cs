using Microsoft.Extensions.DependencyInjection;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.Infrastructure.Services.Azure;

public interface IAdminSingletonService
{
    public Task SendEmail(AdminProcedure model, User originalUser, bool impersonating);


}

public class AdminSingletonService : IAdminSingletonService
{
    readonly IServiceScopeFactory _serviceScopeFactory;
    readonly IBaseEmailService _baseEmailService;
    public AdminSingletonService(IServiceScopeFactory serviceScopeFactory, IBaseEmailService baseEmailService)
    {
        _serviceScopeFactory = serviceScopeFactory;
        _baseEmailService = baseEmailService;
    }


    public async Task SendEmail(AdminProcedure model, User originalUser, bool impersonating)
    {
        await _baseEmailService.SendEmail((token => BuildEmail(model)), originalUser, impersonating);
    }

    private async Task<QuickEmailTemplate> BuildEmail(AdminProcedure model)
    {
        //scoped services need new scope created, since this is being used in singleton (after original scope closure)
        using var scope = _serviceScopeFactory.CreateScope();
        var _repository = scope.ServiceProvider.GetRequiredService<IRepositoryXL<AdminProcedure, AdminResult>>();

        //start tasks to get email data
        AdminProcedure recipientModel = (AdminProcedure)model.Clone();
        recipientModel.SubOp = 1;
        Task<AdminResult> recipientTask = _repository.Op_87(recipientModel);

        AdminProcedure bccModel = (AdminProcedure)model.Clone();
        bccModel.SubOp = 2;
        Task<AdminResult> bccTask = _repository.Op_87(bccModel);

        AdminProcedure otherDataModel = (AdminProcedure)model.Clone();
        otherDataModel.SubOp = 3;
        Task<AdminResult> otherDataTask = _repository.Op_87(otherDataModel);


        //get email adresses
        var test = await recipientTask;
        List<string>? toList = DataParser.GetListFromData((await recipientTask).Data1, "Recipients");
        List<string>? bccList = DataParser.GetListFromData((await bccTask).Data1, "bcc");

        //get subject & body
        var otherData = await otherDataTask;
        string? emailSubject = DataParser.GetValueFromData<string>(otherData.Data1, "Subject");
        string? emailBody = DataParser.GetValueFromData<string>(otherData.Data1, "Body");

        var empName = DataParser.GetValueFromData<string>(otherData.Data1, "EmpName");

        var module = DataParser.GetValueFromData<string>(otherData.Data1, "Module");

        string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        string accessRequestUrl = "https://stingray.brucepower.com/user-management";

        if (env == null || env.Equals("Production", StringComparison.OrdinalIgnoreCase))
        {
            accessRequestUrl = $"https://stingray.brucepower.com/user-management";
        }
        else if (env.Equals("QA", StringComparison.OrdinalIgnoreCase))
        {
            accessRequestUrl = $"https://stingrayqafe.azurewebsites.net/user-management";
        }
        else if (env.Equals("Development", StringComparison.OrdinalIgnoreCase))
        {
            accessRequestUrl = $"https://stingraydevfe.azurewebsites.net/user-management";
        }

        Dictionary<string, string> keyValuePairs = new Dictionary<string, string>();
        keyValuePairs.Add("[EmpName]", empName);
        keyValuePairs.Add("[Module]", module);
        keyValuePairs.Add("[AccessRequestUrl]", accessRequestUrl);

        //empname, module, accessrequesturl

        emailSubject = Template.Populate(emailSubject, keyValuePairs);
        emailBody = Template.Populate(emailBody, keyValuePairs);


        return new QuickEmailTemplate
        {
            toList = toList,
            BCCList = bccList,
            subject = emailSubject,
            emailBody = emailBody
        };
    }
}