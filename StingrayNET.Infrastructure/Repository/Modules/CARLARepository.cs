using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.CARLA;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Models.Common;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class CARLARepository : BaseRepository<CARLAResult>, IRepositoryXL<CARLAProcedure, CARLAResult>
{
    protected override string Query => "stng.SP_CARLA_CRUD";
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IEmailService _emailService;

    public CARLARepository(IDatabase<SC> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<CARLAResult> Op_01(CARLAProcedure model = null)
    {

        return await ExecuteNonQuery<SC>(1, model);
    }

    public async Task<CARLAResult> Op_02(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(2, model);
    }

    public async Task<CARLAResult> Op_03(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(3, model);
    }

    public async Task<CARLAResult> Op_04(CARLAProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(4, model);
    }

    public async Task<CARLAResult> Op_05(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(5, model);
    }

    public async Task<CARLAResult> Op_06(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(6, model);
    }

    public async Task<CARLAResult> Op_07(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(7);
    }

    public async Task<CARLAResult> Op_08(CARLAProcedure model = null)
    {
        //RevisedCommitmentDate should be assign to Value3
        var result = new CARLAResult();
        result.Email = new CARLAResult.EmailResult();
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(8));
        if (model.Value2 == "2")
        {

            var engTechSPOC = DataParser.GetListFromData(data[0], "Email");

            var ActivityIDs = DataParser.GetValueFromData<string>(data[2], "ActivityID");
            var PCSEmail = DataParser.GetValueFromData<string>(data[2], "PCSEmail");
            var PCSName = DataParser.GetValueFromData<string>(data[2], "PCSFullName");
            var PMEmail = DataParser.GetValueFromData<string>(data[2], "ProjectManagerEmail");
            var PMName = DataParser.GetValueFromData<string>(data[2], "ProjectManager");
            var CommitmentOwner = DataParser.GetValueFromData<string>(data[2], "CommitmentOwner");
            var CommitmentOwnerEmail = DataParser.GetValueFromData<string>(data[2], "CommitmentOwnerEmail");
            var CSFLM = DataParser.GetValueFromData<string>(data[2], "CSFLM");
            var CSFLMEmail = DataParser.GetValueFromData<string>(data[2], "CSFLMEmail");
            var ContractAdmin = DataParser.GetValueFromData<string>(data[2], "ContractAdmin");
            var ContractAdminEmail = DataParser.GetValueFromData<string>(data[2], "ContractAdminEmail");


            var CurrentUserEmail = DataParser.GetValueFromData<string>(data[3], "CurrentUserEmail");
            result.Email.EmailBody = DataParser.GetValueFromData<string>(data[1], "EmailBody");
            var Comment = DataParser.GetValueFromData<string>(data[4], "Comment");
            List<string> ccdEmails = new List<string> { PCSEmail, CurrentUserEmail };

            result.Email.To = new List<string> { PMEmail, CommitmentOwnerEmail };
            ccdEmails.Add(CSFLMEmail);
            ccdEmails.Add(ContractAdminEmail);
            ccdEmails.Add(PCSEmail);
            ccdEmails.AddRange(engTechSPOC);
            result.Email.To = result.Email.To.Where(t => !string.IsNullOrEmpty(t)).ToList();
            result.Email.CC = ccdEmails.Where(n => !string.IsNullOrEmpty(n)).Distinct().ToList();

            var keyValuePairs = new Dictionary<string, string>();
            keyValuePairs.Add("[ActivityID]", ActivityIDs);
            keyValuePairs.Add("[Comment]", Comment);
            result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);

            // await _emailService.SendWithCheck(result.Email.To, "Commitment set to At Risk", result.Email.EmailBody, CCList: result.Email.CC);

        }
        return result;


    }

    public async Task<CARLAResult> Op_09(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(9, model);
    }

    public async Task<CARLAResult> Op_10(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(10);
    }

    public async Task<CARLAResult> Op_11(CARLAProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(11, model);
    }

    public async Task<CARLAResult> Op_12(CARLAProcedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 12);
        parameters.AddParameter("@Value1", SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@SubFragnetList", SqlDbType.Structured, model.SubFragnetList);

        CARLAResult result = new CARLAResult();
        var data = await _sc.ExecuteReaderSetAsync(Query, parameters);
        result.Data = data[0][0]; // emailTemplate
        result.Data1 = data[1]; // project info
        result.Data2 = data[2]; // at risk activities

        return result;
    }

    public async Task<CARLAResult> Op_13(CARLAProcedure model = null)
    {

        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<SC>(13, model);
    }

    public async Task<CARLAResult> Op_14(CARLAProcedure model = null)
    {
        var parameters = model.GetParameters(14);

        if (model.Value4 != null) model.ScheduleUpdate = new ScheduleTable<ScheduleUpdate>(model.Value4);
        if (model.Value5 != null) model.SubFragnetList = new ScheduleTable<SubFragnetList>(model.Value5);
        // Automate 
        if ((bool)model.IsTrue1)
        {
            parameters.AddParameter("@ScheduleUpdate", SqlDbType.Structured, model.SubFragnetList);
        }
        else
        {
            parameters.AddParameter("@ScheduleUpdate", SqlDbType.Structured, model.ScheduleUpdate);
        }

        CARLAResult result = new CARLAResult();

        result.Data1 = await _sc.ExecuteReaderAsync(Query, parameters);


        return result;
    }

    public async Task<CARLAResult> Op_15(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(15, model);
    }

    public Task<CARLAResult> Op_16(CARLAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<CARLAResult> Op_17(CARLAProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(17, model);
    }

    public async Task<CARLAResult> Op_18(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(18, model);
    }

    public async Task<CARLAResult> Op_19(CARLAProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(19, model);
    }

    public async Task<CARLAResult> Op_20(CARLAProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(20, model);
    }

    public async Task<CARLAResult> Op_21(CARLAProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(21, model);
    }

    public async Task<CARLAResult> Op_22(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(22, model);
    }

    public Task<CARLAResult> Op_23(CARLAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<CARLAResult> Op_24(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(24, model);
    }

    public Task<CARLAResult> Op_25(CARLAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<CARLAResult> Op_26(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(26, model);
    }

    public async Task<CARLAResult> Op_27(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(27, model);
    }

    public async Task<CARLAResult> Op_28(CARLAProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<SC>(28, model);
    }

    public async Task<CARLAResult> Op_29(CARLAProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<SC>(29, model);
    }

    public async Task<CARLAResult> Op_30(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(30, model);
    }
    public async Task<CARLAResult> Op_31(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(31, model);
    }
    public async Task<CARLAResult> Op_32(CARLAProcedure model = null)
    {

        var result = new CARLAResult();
        result.Email = new CARLAResult.EmailResult();
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(32));
        var engTechSPOC = DataParser.GetListFromData(data[0], "Email");


        var ActivityIDs = DataParser.GetValueFromData<string>(data[2], "ActivityID");
        var PCSEmail = DataParser.GetValueFromData<string>(data[2], "PCSEmail");
        var PCSName = DataParser.GetValueFromData<string>(data[2], "PCSFullName");
        var PlannerEmail = DataParser.GetValueFromData<string>(data[2], "PlannerEmail");
        var PlannerName = DataParser.GetValueFromData<string>(data[2], "PlannerFullName");
        var CurrentUserEmail = DataParser.GetValueFromData<string>(data[3], "CurrentUserEmail");
        result.Email.EmailBody = DataParser.GetValueFromData<string>(data[1], "EmailBody");
        var SeniorPlannerEmail = DataParser.GetValueFromData<string>(data[4], "SeniorPlannerEmail");
        var initiator = DataParser.GetValueFromData<string>(data[5], "Initiator");
        var initiatorEmail = DataParser.GetValueFromData<string>(data[5], "InitiatorEmail");
        List<string> ccdEmails = new List<string> { PCSEmail, CurrentUserEmail };
        if (model.EmailName == "CARLASenttoPlanner")
        {
            result.Email.To = new List<string> { PlannerEmail };
            ccdEmails.Add(SeniorPlannerEmail);
        }
        else
        {
            result.Email.To = new List<string> { initiatorEmail };
            ccdEmails.Add(PlannerEmail);
            ccdEmails.Add(SeniorPlannerEmail);
        }

        ccdEmails.AddRange(engTechSPOC);
        result.Email.To = result.Email.To.Where(t => !string.IsNullOrEmpty(t)).ToList();

        List<string> filteredEmails = ccdEmails.Where(n => !string.IsNullOrEmpty(n)).Distinct().ToList();
        result.Email.CC = filteredEmails;

        var keyValuePairs = new Dictionary<string, string>();
        keyValuePairs.Add("[ActivityID]", ActivityIDs);
        keyValuePairs.Add("[PCS]", PCSName);
        keyValuePairs.Add("[Planner]", PlannerName);
        keyValuePairs.Add("[Initator]", initiator);
        result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);
        return result;
    }
    public async Task<CARLAResult> Op_33(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(33, model);
    }
    public async Task<CARLAResult> Op_34(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(34, model);

    }
    public async Task<CARLAResult> Op_35(CARLAProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<SC>(35, model);
    }
    public async Task<CARLAResult> Op_36(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(36, model);
    }
    public async Task<CARLAResult> Op_37(CARLAProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

        return await ExecuteReader<SC>(37, model);
    }
    public async Task<CARLAResult> Op_38(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(38, model);
    }

    public async Task<CARLAResult> Op_39(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(39, model);
    }
    public async Task<CARLAResult> Op_40(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(40, model);
    }
    public async Task<CARLAResult> Op_41(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(41, model);
    }
    public async Task<CARLAResult> Op_42(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(42, model);
    }
    public async Task<CARLAResult> Op_43(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(43, model);
    }
    public async Task<CARLAResult> Op_44(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(44, model);
    }
    public async Task<CARLAResult> Op_45(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(45, model);
    }

    public async Task<CARLAResult> Op_46(CARLAProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<SC>(46, model);
    }

    public async Task<CARLAResult> Op_47(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(47, model);
    }
    public async Task<CARLAResult> Op_48(CARLAProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<SC>(48, model);
    }
    public async Task<CARLAResult> Op_49(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(49, model);
    }
    public async Task<CARLAResult> Op_50(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(50, model);
    }




    public async Task<CARLAResult> Op_51(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(51, model);
    }
    public async Task<CARLAResult> Op_52(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(52, model);
    }
    public async Task<CARLAResult> Op_53(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(53, model);
    }
    public async Task<CARLAResult> Op_54(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(54, model);
    }
    public async Task<CARLAResult> Op_55(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(55, model);
    }

    public async Task<CARLAResult> Op_56(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(56, model);
    }

    public async Task<CARLAResult> Op_57(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(57, model);
    }
    public async Task<CARLAResult> Op_58(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(58, model);
    }
    public async Task<CARLAResult> Op_59(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(59, model);
    }
    public async Task<CARLAResult> Op_60(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(60, model);
    }




    public async Task<CARLAResult> Op_61(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(61, model);
    }
    public async Task<CARLAResult> Op_62(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(62, model);
    }
    public async Task<CARLAResult> Op_63(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(63, model);
    }
    public async Task<CARLAResult> Op_64(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(64, model);
    }
    public async Task<CARLAResult> Op_65(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(65, model);
    }

    public async Task<CARLAResult> Op_66(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(66, model);
    }

    public async Task<CARLAResult> Op_67(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(67, model);
    }
    public async Task<CARLAResult> Op_68(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(68, model);
    }
    public async Task<CARLAResult> Op_69(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(69, model);
    }
    public async Task<CARLAResult> Op_70(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(70, model);
    }



    public async Task<CARLAResult> Op_71(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(71, model);
    }
    public async Task<CARLAResult> Op_72(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(72, model);
    }
    public async Task<CARLAResult> Op_73(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(73, model);
    }
    public async Task<CARLAResult> Op_74(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(74, model);
    }
    public async Task<CARLAResult> Op_75(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(75, model);
    }

    public async Task<CARLAResult> Op_76(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(76, model);
    }

    public async Task<CARLAResult> Op_77(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(77, model);
    }
    public async Task<CARLAResult> Op_78(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(78, model);
    }
    public async Task<CARLAResult> Op_79(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(79, model);
    }
    public async Task<CARLAResult> Op_80(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(80, model);
    }



    public async Task<CARLAResult> Op_81(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(81, model);
    }
    public async Task<CARLAResult> Op_82(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(82, model);
    }
    public async Task<CARLAResult> Op_83(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(83, model);
    }
    public async Task<CARLAResult> Op_84(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(84, model);
    }
    public async Task<CARLAResult> Op_85(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(85, model);
    }

    public async Task<CARLAResult> Op_86(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(86, model);
    }

    public async Task<CARLAResult> Op_87(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(87, model);
    }
    public async Task<CARLAResult> Op_88(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(88, model);
    }
    public async Task<CARLAResult> Op_89(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(89, model);
    }
    public async Task<CARLAResult> Op_90(CARLAProcedure model = null)
    {
        return await ExecuteReader<SC>(90, model);
    }








}
