using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.ER;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Specifications;
using Microsoft.AspNetCore.Http;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore;
using System.Data;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.HelperFunctions;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class ERRepository : BaseRepository<ERResult>, IRepositoryXL<ERProcedure, ERResult>
{
    protected override string Query => "stng.SP_ER_CRUD";

    private IHttpContextAccessor _httpContextAccessor;
    readonly IBaseEmailService _baseEmailService;

    public ERRepository(IDatabase<DED> ded, IDatabase<SC> sc, IBaseEmailService baseEmailService, IHttpContextAccessor httpContextAccessor) : base(ded, sc)
    {
        _httpContextAccessor = httpContextAccessor;
        _baseEmailService = baseEmailService;
    }

    private async Task<QuickEmailTemplate> BuildEmail(Procedure model)
    {

        model.SubOp = 1;
        ERResult toEmails = await ExecuteReader<DED>(44, model);

        model.SubOp = 2;
        ERResult miscData = await ExecuteReader<DED>(44, model);

        model.SubOp = 3;
        ERResult emailTemplate = await ExecuteReader<DED>(44, model);

        model.SubOp = 4;
        ERResult deliverables = await ExecuteReader<DED>(44, model);

        model.SubOp = 5;
        ERResult ccEmails = await ExecuteReader<DED>(44, model);

        model.SubOp = 6;
        ERResult resources = await ExecuteReader<DED>(44, model);

        QuickEmailTemplate email = new QuickEmailTemplate();

        //email template
        var subject = DataParser.GetValueFromData<string>(emailTemplate.Data1, "Subject");
        var body = DataParser.GetValueFromData<string>(emailTemplate.Data1, "Body");

        email.toList = DataParser.GetListFromData(toEmails.Data1, "Email");
        email.CCList = DataParser.GetListFromData(ccEmails.Data1, "Email");

        //fields
        var ER = DataParser.GetValueFromData<string>(miscData.Data1, "ER");
        var Section = DataParser.GetValueFromData<string>(miscData.Data1, "SectionName");
        var tweek = DataParser.GetValueFromData<string>(miscData.Data1, "TweekCalc");
        var tcd = DataParser.GetValueFromData<string>(miscData.Data1, "ERTCD");

        //Inserted Values
        var keyValuePairs = new Dictionary<string, string>
        {
            { "[ER]", ER },
            { "[Section]", Section },
            { "[Tweek]", tweek },
            { "[TCD]", DateTime.Parse(tcd).Date.ToString("dd MMM yyyy") }
        };

        //hyperlink dependent on environment
        string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        string DeepLink = "https://stingray.brucepower.com/er";

        if (env == null || env.Equals("Production", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingray.brucepower.com/ER?ER={ER}";
        }
        else if (env.Equals("QA", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingrayqafe.azurewebsites.net/ER?ER={ER}";
        }
        else if (env.Equals("Development", StringComparison.OrdinalIgnoreCase))
        {
            DeepLink = $"https://stingraydevfe.azurewebsites.net/ER?ER={ER}";
        }
        keyValuePairs.Add("[DeepLink]", DeepLink);

        List<object> delivData = deliverables.Data1;

        List<object> resourceData = resources.Data1;

        var resourceTable = "<style>table{border-style: solid;border-width:1px;border-color: black;border-collapse: collapse;}</style><table cellpadding=5 cellspacing=0 border='1'><tr> <td bgcolor=#E6E6FA><b>Resource</b></td><td bgcolor=#E6E6FA><b>Resource Type</b></td>";

        for (int i = 0; i < resourceData.Count; i++)
        {
            resourceTable += "<tr><td>[ResourceC" + i.ToString() + "]</td><td>[ResourceTypeC" + i.ToString() + "]</td>";
            keyValuePairs.Add($"[ResourceC{i}]", ((Dictionary<string, object>)resourceData[i])["ResourceC"].Equals("") ? "" : ((Dictionary<string, object>)resourceData[i])["ResourceC"].ToString());
            keyValuePairs.Add($"[ResourceTypeC{i}]", ((Dictionary<string, object>)resourceData[i])["ResourceTypeC"].Equals("") ? "" : ((Dictionary<string, object>)resourceData[i])["ResourceTypeC"].ToString());

        }
        resourceTable += "</table>";

        resourceTable = Template.Populate(resourceTable, keyValuePairs);
        keyValuePairs.Add("[ResourceTable]", resourceTable);

        //Deliverable Table

        var deliverableTable = "<style>table{border-style: solid;border-width:1px;border-color: black;border-collapse: collapse;}</style><table cellpadding=5 cellspacing=0 border='1'><tr> <td bgcolor=#E6E6FA><b>Deliverable Title</b></td><td bgcolor=#E6E6FA><b>Total Hours</b></td><td bgcolor=#E6E6FA><b>In House</b></td><td bgcolor=#E6E6FA><b>Vendor</b></td>";

        for (int i = 0; i < delivData.Count; i++)
        {
            deliverableTable += "<tr><td>[DelName" + i.ToString() + "]</td><td>[EstimatedHours" + i.ToString() + "]</td><td>[InHouse" + i.ToString() + "]</td><td>[VendorName" + i.ToString() + "]</td>";
            keyValuePairs.Add($"[DelName{i}]", ((Dictionary<string, object>)delivData[i])["DelName"].Equals("") ? "" : ((Dictionary<string, object>)delivData[i])["DelName"].ToString());
            keyValuePairs.Add($"[EstimatedHours{i}]", ((Dictionary<string, object>)delivData[i])["EstimatedHours"].Equals("") ? "" : ((double)((Dictionary<string, object>)delivData[i])["EstimatedHours"]).ToString("0.00"));
            keyValuePairs.Add($"[InHouse{i}]", ((Dictionary<string, object>)delivData[i])["InHouse"].Equals("") ? "" : ((bool)((Dictionary<string, object>)delivData[i])["InHouse"]).ToString());
            keyValuePairs.Add($"[VendorName{i}]", ((Dictionary<string, object>)delivData[i])["VendorName"].Equals("") ? "" : ((Dictionary<string, object>)delivData[i])["VendorName"].ToString());

        }
        deliverableTable += "</table>";

        deliverableTable = Template.Populate(deliverableTable, keyValuePairs);
        keyValuePairs.Add("[DeliverableTable]", deliverableTable);


        email.subject = Template.Populate(subject, keyValuePairs);
        email.emailBody = Template.Populate(body, keyValuePairs);

        return email;
    }

    public async Task<ERResult> Op_45(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(45, model);
    }

    public Task<ERResult> Op_44(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<ERResult> Op_43(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(43, model);
    }

    public async Task<ERResult> Op_42(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(42, model);
    }

    public async Task<ERResult> Op_41(ERProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(41, model);
    }

    public async Task<ERResult> Op_40(ERProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(40, model);
    }

    public async Task<ERResult> Op_39(ERProcedure model = null)
    {

        var scModel = new AdminProcedure
        {
            EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString(),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }

        return await ExecuteReader<DED>(39, model);
    }

    public async Task<ERResult> Op_38(ERProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(38, model);
    }

    public async Task<ERResult> Op_37(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(37, model);
    }

    public async Task<ERResult> Op_36(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(36, model);
    }

    public async Task<ERResult> Op_35(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(35, model);
    }

    public async Task<ERResult> Op_34(ERProcedure model = null)
    {
        var result = new ERResult();

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 34);
        parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 1);
        parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.ERID));

        List<object> vendors = await _ded.ExecuteReaderAsync(Query, parameters);

        foreach (object vendor in vendors)
        {
            if (vendor is Dictionary<string, object> dict)
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 34);
                parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 2);
                parameters.AddParameter("@ERID", SqlDbType.UniqueIdentifier, Guid.Parse(model.ERID));
                parameters.AddParameter("@VendorID", SqlDbType.UniqueIdentifier, dict["Vendor"]);

                await _ded.ExecuteReaderAsync(Query, parameters);
            }

        }

        return result;
    }

    public async Task<ERResult> Op_33(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(33, model);
    }

    public async Task<ERResult> Op_32(ERProcedure model = null)
    {
        ERResult result = await ExecuteReaderValidation<DED>(32, model);
        string? returnMessage = DataParser.GetValueFromData<string>(result.Data1, "ReturnMessage");
        if (returnMessage == null)
        {
            if (model.StatusShort == "EXE")
            {
                User? originalUser = (User)_httpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"];
                bool impersonating = _httpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS");

                Procedure emailModel = new Procedure();
                emailModel.Value2 = model.UniqueID;

                await _baseEmailService.SendEmail(token => BuildEmail(emailModel), originalUser, impersonating);
            }


        }

        return result;
    }

    public async Task<ERResult> Op_31(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(31, model);
    }

    public async Task<ERResult> Op_30(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(30, model);

    }

    public async Task<ERResult> Op_29(ERProcedure model = null)
    {
        var scModel = new AdminProcedure
        {
            EmployeeID = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }

        return await ExecuteReaderValidation<DED>(29, model);

    }

    public async Task<ERResult> Op_28(ERProcedure model = null)
    {
        var scModel = new AdminProcedure
        {
            EmployeeID = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }

        return await ExecuteReaderValidation<DED>(28, model);

    }

    public async Task<ERResult> Op_27(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<ERResult> Op_26(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<ERResult> Op_25(ERProcedure model = null)
    {
        var scModel = new AdminProcedure
        {
            EmployeeID = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }

        return await ExecuteReaderValidation<DED>(25, model);
    }

    public async Task<ERResult> Op_24(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<ERResult> Op_23(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<ERResult> Op_22(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<ERResult> Op_21(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<ERResult> Op_20(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<ERResult> Op_19(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<ERResult> Op_18(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<ERResult> Op_17(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<ERResult> Op_16(ERProcedure model = null)
    {
        var result = new ERResult();

        foreach (var assessment in model.Assessments)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 16);
            parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 1);
            parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
            parameters.AddParameter("@Assessment", SqlDbType.UniqueIdentifier, Guid.Parse(assessment.id));

            List<object> assessments = await _ded.ExecuteReaderAsync(Query, parameters);
            if ((assessment.value && assessments.Count > 0) || (!assessment.value && assessments.Count == 0))
            {
                continue;
            }
            else if (assessment.value)
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 16);
                parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 2);
                parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
                parameters.AddParameter("@Assessment", SqlDbType.UniqueIdentifier, Guid.Parse(assessment.id));
                parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
            else
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 16);
                parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 3);
                parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
                parameters.AddParameter("@Assessment", SqlDbType.UniqueIdentifier, Guid.Parse(assessment.id));

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
        }

        return result;
    }

    public async Task<ERResult> Op_15(ERProcedure model = null)
    {

        var scModel = new AdminProcedure
        {
            EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString(),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }

        return await ExecuteReaderValidation<DED>(15, model);
    }

    public async Task<ERResult> Op_14(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<ERResult> Op_13(ERProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(13, model);
    }

    public async Task<ERResult> Op_12(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<ERResult> Op_11(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public Task<ERResult> Op_10(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<ERResult> Op_09(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }
    public async Task<ERResult> Op_08(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }
    public async Task<ERResult> Op_07(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }
    public async Task<ERResult> Op_06(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }
    public async Task<ERResult> Op_05(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }
    public async Task<ERResult> Op_04(ERProcedure model = null)
    {
        var scModel = new AdminProcedure
        {
            EmployeeID = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }

        return await ExecuteReaderValidation<DED>(4, model);
    }
    public async Task<ERResult> Op_03(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }
    public async Task<ERResult> Op_02(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }
    public async Task<ERResult> Op_01(ERProcedure model = null)
    {

        var scModel = new AdminProcedure
        {
            EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString(),
            Permission = "ERAdminEdit"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.isAdmin = true;

        }
        return await ExecuteReader<DED>(1, model);
    }

    public Task<ERResult> Op_90(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_89(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_88(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_87(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_86(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_85(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_84(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_83(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_82(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_81(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_80(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_79(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_78(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_77(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_76(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_75(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_74(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_73(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_72(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_71(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_70(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_69(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_68(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_67(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_66(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_65(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_64(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_63(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_62(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_61(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_60(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_59(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_58(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_57(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_56(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_55(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_54(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_53(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_52(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_51(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_50(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_49(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ERResult> Op_48(ERProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<ERResult> Op_47(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(47, model);
    }

    public async Task<ERResult> Op_46(ERProcedure model = null)
    {
        return await ExecuteReader<DED>(46, model);
    }
}
