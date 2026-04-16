using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.MPL;
using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class MPLRepository : BaseRepository<MPLResult>, IRepositoryL<MPLProcedure, MPLResult>
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    private readonly IEmailService _emailService;

    private readonly IIdentityService _identityService;

    public MPLRepository(IDatabase<SC> mssql, IHttpContextAccessor httpContextAccessor, IEmailService emailService, IIdentityService identityService) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
        _emailService = emailService;
        _identityService = identityService;
    }

    protected override string Query => "stng.SP_MPL_CRUD";

    public async Task<MPLResult> Op_01(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(1);
    }

    public async Task<MPLResult> Op_02(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(2);
    }

    public async Task<MPLResult> Op_03(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(3);
    }

    public async Task<MPLResult> Op_04(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(4);
    }

    public async Task<MPLResult> Op_05(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(5, model);
    }

    public async Task<MPLResult> Op_06(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(6);
    }


    public async Task<MPLResult> Op_07(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(7);
    }

    public async Task<MPLResult> Op_08(MPLProcedure model = null)
    {
        var result = new MPLResult();
        result.Email = new MPLResult.EmailResult();
        model.CurrentUser = await _identityService.GetEmployeeID(_httpContextAccessor.HttpContext);

        List<object> returnList = new List<object>();
        var emailRows = new StringBuilder(); // This will hold the rows for the tab
        var keyValuePairs = new Dictionary<string, string>();

        foreach (var solution in model.Solutions)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 8);
            parameters.AddParameter("@ProjectID", SqlDbType.NVarChar, solution.ProjectID);
            parameters.AddParameter("@field", SqlDbType.VarChar, solution.field);
            parameters.AddParameter("@OldValue", SqlDbType.NVarChar, solution.OldValue);
            parameters.AddParameter("@NewValue", SqlDbType.NVarChar, solution.NewValue);
            parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);
            parameters.AddParameter("@NDQDate", SqlDbType.VarChar, solution.NDQDate);
            parameters.AddParameter("@ResumeDate", SqlDbType.VarChar, solution.ResumeDate);

            var a = await _sc.ExecuteReaderAsync(Query, parameters);

            if (a.Count > 0)
            {
                returnList.Add(a[0]);
            }
        }

        // Task.Run(async () => await Op_22(model));
        var data1 = await ExecuteReader<SC>(22);
        var data = data1.Data2;
        var data3 = data1.Data3;
        var data4 = data1.Data4;
        foreach (dynamic row in data)
        {
            var Field = row["Field"]?.ToString();
            var ChangeFrom = row["ChangeFrom"]?.ToString();
            var ChangeTo = row["ChangeTo"]?.ToString();
            var NdqDate = row["NDQ_DATE"]?.ToString();
            var ResumeDate = row["Resume_Date"]?.ToString();

            emailRows.AppendLine("<tr>");
            emailRows.AppendLine($"<td>{Field}</td>");
            emailRows.AppendLine($"<td>{ChangeFrom}</td>");
            emailRows.AppendLine($"<td>{ChangeTo}</td>");
            if (!string.IsNullOrEmpty(NdqDate))
            {
                emailRows.AppendLine($"<td>{NdqDate}</td>");
            }
            if (!string.IsNullOrEmpty(ResumeDate))
            {
                emailRows.AppendLine($"<td>{ResumeDate}</td>");
            }
            emailRows.AppendLine("</tr>");
        }

        var PCSEmail = DataParser.GetValueFromData<string>(data3, "PCSEmail");
        var ProjectID = DataParser.GetValueFromData<string>(data3, "ProjectNo");
        var ProjectName = DataParser.GetValueFromData<string>(data3, "ProjectName");
        var OEEmail = DataParser.GetValueFromData<string>(data3, "OEEmail");
        var Requester = DataParser.GetValueFromData<string>(data3, "ActionBy");
        var PlannerEmail = DataParser.GetValueFromData<string>(data3, "ProjectPlannerEmail");
        var Approver = DataParser.GetValueFromData<string>(data3, "ENGSM");
        var ApproverEmail = DataParser.GetValueFromData<string>(data3, "ENGSMEmail");
        var ActionByEmail = DataParser.GetValueFromData<string>(data3, "actionbyemail");
        var LeadPlanner = DataParser.GetValueFromData<string>(data3, "leadplanner");
        var DMEP = DataParser.GetValueFromData<string>(data3, "DMEP");
        var PCSManager = DataParser.GetValueFromData<string>(data3, "pcsmanager");

        result.Email.EmailBody = DataParser.GetValueFromData<string>(data1.Data1, "EmailBody");
        var emailBody = result.Email.EmailBody.Replace("[EmailRows]", emailRows.ToString());

        result.Email.To = new List<string> {
                         LeadPlanner
                 };

        foreach (dynamic row in data)
        {
            var Field = row["Field"]?.ToString();
            if (Field == "Project Control Specialist")
            {
                result.Email.To.Add(PCSManager);
            }
            if (Field == "Owners Engineering Lead")
            {
                result.Email.To.Add(ApproverEmail);
            }
            if (Field == "Status")
            {
                result.Email.To.Add(DMEP);
            }
        }

        result.Email.To = result.Email.To.Where(t => !string.IsNullOrEmpty(t)).ToList();
        result.Email.CC = new List<string> { ActionByEmail };
        result.Email.To = result.Email.To.Distinct().ToList();
        result.Email.CC = result.Email.CC.Distinct().ToList();
        keyValuePairs.Add("[ProjectID]", ProjectID);
        keyValuePairs.Add("[ProjectName]", ProjectName);
        keyValuePairs.Add("[Requester]", Requester);

        // Populate email body template with consolidated details
        result.Email.EmailBody = Template.Populate(emailBody, keyValuePairs);
        result.Data1 = returnList;
        return result;
    }

    public async Task<MPLResult> Op_09(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(9);
    }

    public async Task<MPLResult> Op_10(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(10, model);
    }

    public async Task<MPLResult> Op_11(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(11, model);
    }

    public async Task<MPLResult> Op_12(MPLProcedure model = null)
    {

        var result = new MPLResult();
        result.Email = new MPLResult.EmailResult();
        model.CurrentUser = await _identityService.GetEmployeeID(_httpContextAccessor.HttpContext);
        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(12));

        var Field = DataParser.GetValueFromData<string>(data[1], "Field");
        var ChangeFrom = DataParser.GetValueFromData<string>(data[1], "ChangeFrom");
        var ChangeTo = DataParser.GetValueFromData<string>(data[1], "ChangeTo");
        var Approved = DataParser.GetValueFromData<string>(data[1], "Approved");
        var ProjectID = DataParser.GetValueFromData<string>(data[1], "ProjectNo");
        var Requester = DataParser.GetValueFromData<string>(data[1], "ActionBy");
        var PCSEmail = DataParser.GetValueFromData<string>(data[1], "PCSEmail");
        var OEEmail = DataParser.GetValueFromData<string>(data[1], "OEEmail");
        var PlannerEmail = DataParser.GetValueFromData<string>(data[1], "ProjectPlannerEmail");
        var Approver = DataParser.GetValueFromData<string>(data[1], "ENGSM");
        var ApproverEmail = DataParser.GetValueFromData<string>(data[1], "ENGSMEmail");
        var ActionByEmail = DataParser.GetValueFromData<string>(data[1], "actionbyemail");
        var NDQDate = DataParser.GetValueFromData<string>(data[1], "NDQ_DATE");
        var ResumeDate = DataParser.GetValueFromData<string>(data[1], "Resume_Date");
        var Comment = DataParser.GetValueFromData<string>(data[1], "Comment");
        var currentuseremail = DataParser.GetValueFromData<string>(data[2], "CurrentUserEmail");
        result.Email.EmailBody = DataParser.GetValueFromData<string>(data[0], "EmailBody");

        if (Approved == "True")
        {
            result.Email.To = new List<string> { PlannerEmail, ActionByEmail, "bnpdesdprojectbaseliningrequest@brucepower.com" };
            result.Email.CC = new List<string> { PCSEmail, currentuseremail };
        }
        else
        {
            result.Email.To = new List<string> { currentuseremail, ActionByEmail };
        }

        result.Email.To = result.Email.To.Where(t => !string.IsNullOrEmpty(t)).ToList();
        var keyValuePairs = new Dictionary<string, string>();
        keyValuePairs.Add("[ProjectID]", ProjectID);
        keyValuePairs.Add("[Field]", Field);
        keyValuePairs.Add("[ChangeFrom]", ChangeFrom);
        keyValuePairs.Add("[ChangeTo]", ChangeTo);
        keyValuePairs.Add("[Comment]", Comment);
        if (!string.IsNullOrEmpty(NDQDate))
        {
            keyValuePairs.Add("[NDQDate]", NDQDate);
        }

        else { keyValuePairs.Add("[NDQDate]", "N/A"); }
        if (!string.IsNullOrEmpty(ResumeDate))
        {
            keyValuePairs.Add("[ResumeDate]", ResumeDate);
        }

        else { keyValuePairs.Add("[ResumeDate]", "N/A"); }
        result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);
        return result;

    }

    public async Task<MPLResult> Op_13(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(13, model);
    }

    public async Task<MPLResult> Op_14(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(14, model);
    }

    public async Task<MPLResult> Op_15(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(15, model);
    }

    public async Task<MPLResult> Op_16(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(16, model);
    }

    public async Task<MPLResult> Op_17(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(17, model);
    }

    public async Task<MPLResult> Op_18(MPLProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var origResult = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(18));
        var user = await _identityService.GetUser(_httpContextAccessor.HttpContext);
        var userEmail = user.Email;

        string emailBody = DataParser.GetValueFromData<string>(origResult[3], @"EmailBody");
        string sendTo = DataParser.GetValueFromData<string>(origResult[3], @"SendTo");


        if (origResult[0].Count > 0)
        {
            string emailBodyTable1 = await _emailService.ToHTMLTable(origResult[0]);
            string emailBody1 = await _emailService.Inject(emailBody, new Dictionary<string, string>() { { @"P6UpdateList", emailBodyTable1 } });

            EmailTemplate template = new EmailTemplate(toList: new List<string>() { sendTo }, subject: @"P6 Change request for Lead Planner", emailBody: emailBody1, CCList: new List<string>() { userEmail });

            await _emailService.Send(template);
        }

        if (origResult[1].Count > 0)
        {
            string emailBodyTable2 = await _emailService.ToHTMLTable(origResult[1]);
            string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>() { { @"P6UpdateList", emailBodyTable2 } });

            EmailTemplate template = new EmailTemplate(toList: new List<string>() { sendTo, "bnpdesdprojectbaseliningrequest@brucepower.com" }, subject: @"P6 Change request for Planner", emailBody: emailBody2, CCList: new List<string>() { userEmail });

            await _emailService.Send(template);
        }

        if (origResult[2].Count > 0)
        {
            string emailBodyTable3 = await _emailService.ToHTMLTable(origResult[2]);
            string emailBody3 = await _emailService.Inject(emailBody, new Dictionary<string, string>() { { @"P6UpdateList", emailBodyTable3 } });

            EmailTemplate template = new EmailTemplate(toList: new List<string>() { sendTo }, subject: @"P6 Change request for Intern", emailBody: emailBody3, CCList: new List<string>() { userEmail });

            await _emailService.Send(template);
        }
        var mplResult = new MPLResult { Data1 = origResult[0], Data2 = origResult[1], Data3 = origResult[2], Data4 = origResult[3] };
        return mplResult;
    }

    public async Task<MPLResult> Op_19(MPLProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var origResult = await ExecuteReader<SC>(19, model);
        var result = origResult;
        var user = await _identityService.GetUser(_httpContextAccessor.HttpContext);
        var userEmail = user.Email;

        string emailBody = DataParser.GetValueFromData<string>(result.Data3, @"EmailBody");

        if (result.Data1.Count > 0)
        {
            string emailBodyTable1 = await _emailService.ToHTMLTable(result.Data1);
            string emailBody1 = await _emailService.Inject(emailBody, new Dictionary<string, string>() { { @"P6UpdateList", emailBodyTable1 } });

            EmailTemplate template = new EmailTemplate(toList: new List<string>() { @"neel.shah@brucepower.com" }, subject: @"P6 Change request for Lead Planner - User Replacement", emailBody: emailBody1, CCList: new List<string>() { userEmail });

            await _emailService.Send(template);
        }

        if (result.Data2.Count > 0)
        {
            string emailBodyTable2 = await _emailService.ToHTMLTable(result.Data2);
            string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>() { { @"P6UpdateList", emailBodyTable2 } });

            EmailTemplate template = new EmailTemplate(toList: new List<string>() { @"neel.shah@brucepower.com" }, subject: @"P6 Change request for Planner - User Replacement", emailBody: emailBody2, CCList: new List<string>() { userEmail });

            await _emailService.Send(template);
        }

        return origResult;
    }

    public async Task<MPLResult> Op_20(MPLProcedure model = null)
    {
        // return new Either<MPLResult, Exception>(new MPLResult() { ChangeRequestID = Guid.NewGuid().ToString() });
        return new MPLResult();
    }

    public async Task<MPLResult> Op_21(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(21);
    }

    public async Task<MPLResult> Op_22(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(22);
    }

    public async Task<MPLResult> Op_23(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(23, model);
    }

    public async Task<MPLResult> Op_24(MPLProcedure model = null)
    {
        return await ExecuteReader<SC>(24, model);
    }

    public Task<MPLResult> Op_25(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_26(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_27(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_28(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_29(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_30(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_31(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_32(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_33(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_34(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_35(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_36(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_37(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_38(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_39(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_40(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_41(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_42(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_43(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_44(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MPLResult> Op_45(MPLProcedure model = null)
    {
        throw new NotImplementedException();
    }
}