using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.ETDB;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class ETDBRepository : BaseRepository<ETDBResult>, IRepositoryM<ETDBProcedure, ETDBResult>
{
    protected override string Query => "stng.SP_ETDB_CRUD";
    private readonly IHttpContextAccessor _httpContext;
    private readonly IIdentityService _identityService;


    public ETDBRepository(IDatabase<SC> mssql, IHttpContextAccessor httpContext, IIdentityService identityService) : base(mssql)
    {
        _httpContext = httpContext;
        _identityService = identityService;
    }

    public async Task<ETDBResult> Op_15(ETDBProcedure model = null)
    {

        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 15);
        parameters.AddParameter("@EmployeeID", System.Data.SqlDbType.Int, model.EmployeeID);
        parameters.AddParameter("@SubOp", System.Data.SqlDbType.TinyInt, model.SubOp);
        parameters.AddParameter("@Value1", System.Data.SqlDbType.VarChar, model.TDS.Title);
        parameters.AddParameter("@Value2", System.Data.SqlDbType.VarChar, model.TDS.SheetID);
        parameters.AddParameter("@Value3", System.Data.SqlDbType.VarChar, model.TDS.Type);
        parameters.AddParameter("@Value4", System.Data.SqlDbType.VarChar, model.TDS.Group);
        parameters.AddParameter("@Value5", System.Data.SqlDbType.VarChar, model.TDS.CommitmentID);
        parameters.AddParameter("@Value6", System.Data.SqlDbType.VarChar, model.TDS.Initiator);
        parameters.AddParameter("@Value7", System.Data.SqlDbType.VarChar, model.TDS.ProjectID);
        parameters.AddParameter("@Date1", System.Data.SqlDbType.DateTime, model.TDS.NeedDate);
        parameters.AddParameter("@IsTrue1", System.Data.SqlDbType.Bit, model.TDS.Emergent);
        parameters.AddParameter("@IsTrue2", System.Data.SqlDbType.Bit, model.TDS.External);
        parameters.AddParameter("@Value8", System.Data.SqlDbType.VarChar, model.TDS.Description);
        parameters.AddParameter("@PressureBoundaryReview", System.Data.SqlDbType.Bit, model.TDS.PressureBoundaryReview);
        var sdTable = new TableType<SDTable>(model.Value1);
        parameters.AddParameter("@Detail", System.Data.SqlDbType.Structured, sdTable);

        var result = new ETDBResult();
        result.RowsAffected = await _sc.ExecuteNonQueryAsync(Query, parameters);
        return result;
    }

    public async Task<ETDBResult> Op_14(ETDBProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(14, model);
    }

    // Issues Email
    public async Task<ETDBResult> Op_13(ETDBProcedure model = null)
    {
        var result = new ETDBResult();
        result.Email = new ETDBResult.EmailResult();

        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(13));
        if (model.IsTrue1 is true)
        {
            result.Email.EmailBody = DataParser.GetValueFromData<string>(data[0], "Template");

            var pm = DataParser.GetValueFromData<string>(data[1], "ProjectManager");
            var title = DataParser.GetValueFromData<string>(data[1], "Title");
            var flaggedBy = DataParser.GetValueFromData<string>(data[1], "FlaggedBy");
            var status = DataParser.GetValueFromData<string>(data[1], "Status");
            var commitmentID = DataParser.GetValueFromData<string>(data[1], "CommitmentID");
            var needDate = DataParser.GetValueFromData<string>(data[1], "NeedDate");
            var Comment = DataParser.GetValueFromData<string>(data[1], "LatestComment");
            var latestComment = Comment.Replace("\r\n", "<br>").Replace("\n", "<br>");
            var projectID = DataParser.GetValueFromData<string>(data[1], "ProjectID");
            var createdBy = DataParser.GetValueFromData<string>(data[1], "CreatedBy");
            var createdDate = DataParser.GetValueFromData<string>(data[1], "CreatedDate");
            var initiatorEmail = DataParser.GetValueFromData<string>(data[1], "Initiator");
            var assigned = DataParser.GetValueFromData<string>(data[1], "AssignedEmail");
            var engTech = DataParser.GetListFromData(data[2], "Email"); // eng-tech spoc
            var flaggedByEmail = DataParser.GetValueFromData<string>(data[1], "FlaggedByEmail"); // eng-tech spoc
            var oeEmail = DataParser.GetValueFromData<string>(data[1], "OwnersEngineeremail");
            var flmEmail = DataParser.GetValueFromData<string>(data[1], "CSFLMemail");
            var pmEmail = DataParser.GetValueFromData<string>(data[1], "ProjectManagerEmail");
            var pcsEmail = DataParser.GetValueFromData<string>(data[1], "PCSEmail");
            var mbEmail = DataParser.GetValueFromData<string>(data[1], "MaterialBuyerEmail");

            result.Email.To = new List<string> { pmEmail, initiatorEmail, mbEmail };
            result.Email.CC = new List<string> { oeEmail, pcsEmail, flaggedByEmail };
            result.Email.CC.AddRange(engTech);
            if (assigned != null)
            {
                result.Email.CC.AddRange(assigned.Split(","));
            }

            // Add FLM if TDS is Escalated
            if ((bool)model.IsTrue2) result.Email.CC.Add(flmEmail);

            // Remove any duplicates
            result.Email.CC = result.Email.CC?
                .Where(e => !string.IsNullOrEmpty(e))
                .Select(e => e.ToLower())
                .Distinct().ToList();

            var keyValuePairs = new Dictionary<string, string>
                {
                    { "[Namelist]", pm },
                    { "[ProjectID]", projectID },
                    { "[TDS]", model.Value1 },
                    { "[Title]", title },
                    { "[Status]", status },
                    { "[NeedDate]", needDate },
                    { "[CreatedBy]", createdBy },
                    { "[CreatedDate]", createdDate },
                    { "[CommitmentID]", commitmentID ?? "" },
                    { "[Initiator]", initiatorEmail },
                    { "[FlaggedBy]", flaggedBy },
                    { "[LatestComment]", latestComment ?? "" }
                };
            result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);
        }
        return result;
    }

    // Tempus Pick emails
    public async Task<ETDBResult> Op_12(ETDBProcedure model = null)
    {
        var result = new ETDBResult();
        result.Email = new ETDBResult.EmailResult();

        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(12));
        var engTechSPOC = DataParser.GetListFromData(data[0], "Email");
        var tempPickSPOCEmail = DataParser.GetListFromData(data[3], "Email");
        var tempPickSPOCName = DataParser.GetListFromData(data[3], "FullName");
        result.Email.EmailBody = DataParser.GetValueFromData<string>(data[1], "EmailBody");

        string ca = DataParser.GetValueFromData<string>(data[2], "CostAnalyst");

        var caLANID = DataParser.GetValueFromData<string>(data[2], "CostAnalystLANID");
        var projectManagerLANID = DataParser.GetValueFromData<string>(data[2], "ProjectManagerLANID");
        string caEmail = DataParser.GetValueFromData<string>(data[2], "CostAnalystEmail");
        string pmEmail = DataParser.GetValueFromData<string>(data[2], "ProjectManagerEmail");

        result.Email.To = new List<string> {

                    caEmail.ToLower()
                };
        tempPickSPOCName.Add(ca);
        result.Email.To.AddRange(tempPickSPOCEmail);
        result.Email.To = result.Email.To.Where(t => !string.IsNullOrEmpty(t)).ToList();
        result.Email.CC = engTechSPOC;
        result.Email.CC.Add(pmEmail);

        var keyValuePairs = new Dictionary<string, string>();

        var namelist = string.Join("; ", tempPickSPOCName.Where(n => !string.IsNullOrEmpty(n)));
        keyValuePairs.Add("[Namelist]", namelist);
        keyValuePairs.Add("[PROJ]", model.Value1);
        result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);
        return result;
    }

    //Completion Emails
    public async Task<ETDBResult> Op_11(ETDBProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        var result = new ETDBResult();
        result.Email = new ETDBResult.EmailResult();
        List<string> assignedEmails = new List<string> { };

        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(11));

        var engTechSpoc = DataParser.GetListFromData(data[0], "Email"); // eng-tech spoc
        result.Email.EmailBody = DataParser.GetValueFromData<string>(data[1], "EmailBody");

        var initiatorEmail = DataParser.GetValueFromData<string>(data[2], "Initiator");
        var pcsLANID = DataParser.GetValueFromData<string>(data[2], "PCSLANID");
        var materialBuyerLANID = DataParser.GetValueFromData<string>(data[2], "MaterialBuyerLANID");
        var projectManagerLANID = DataParser.GetValueFromData<string>(data[2], "ProjectManagerLANID");
        var buyerAnalystLANID = DataParser.GetValueFromData<string>(data[2], "BuyerAnalystLANID");
        var assignedEmailString = DataParser.GetValueFromData<string>(data[2], "AssignedEmail");
        var title = DataParser.GetValueFromData<string>(data[2], "Title");
        var commitmentID = DataParser.GetValueFromData<string>(data[2], "CommitmentID");
        var Comment = DataParser.GetValueFromData<string>(data[2], "LatestComment");
        string pcsEmail = DataParser.GetValueFromData<string>(data[2], "PCSEmail"); ;
        string materialBuyerEmail = DataParser.GetValueFromData<string>(data[2], "MaterialBuyerEmail");
        string projectManagerEmail = DataParser.GetValueFromData<string>(data[2], "ProjectManagerEmail");
        string buyerAnalystEmail = DataParser.GetValueFromData<string>(data[2], "BuyerAnalystEmail");
        var latestComment = Comment.Replace("\r\n", "<br>").Replace("\n", "<br>");
        string status = null;

        if (!string.IsNullOrEmpty(assignedEmailString))
        {
            assignedEmails = assignedEmailString.Split(',').ToList();
        }

        assignedEmails = string.IsNullOrEmpty(assignedEmailString)
            ? new List<string>()
            : assignedEmailString.Split(',').ToList();
        var ccdEmails = new List<string>();
        List<string> Filter(params string[] emails) =>
            emails.Where(e => !string.IsNullOrWhiteSpace(e)).ToList();

        if (model.Num1 == 5 || model.Num1 == 6)
        {
            result.Email.To = Filter(projectManagerEmail, initiatorEmail, buyerAnalystEmail, materialBuyerEmail);
            ccdEmails.AddRange(Filter(pcsEmail)); // in case pcsEmail could be null/empty
            ccdEmails.AddRange(engTechSpoc);
            ccdEmails.AddRange(assignedEmails);
        }
        else if (model.Num1.HasValue || !string.IsNullOrWhiteSpace(model.Comment))
        {
            result.Email.To = Filter(pcsEmail);
            ccdEmails.AddRange(engTechSpoc);
        }

        List<string> filteredEmails = ccdEmails.Where(n => !string.IsNullOrEmpty(n)).Distinct().ToList();
        result.Email.CC = filteredEmails;

        var keyValuePairs = new Dictionary<string, string>
         {
              { "[Namelist]", "" },
              { "[CommitmentID]", commitmentID },
              { "[Title]", title },
              { "[TDS]", model.Value1 },
              { "[Initiator]", initiatorEmail },
              { "[LatestComment]", latestComment }
        };
        if (model.Num1.HasValue)
        {
            status = DataParser.GetValueFromData<string>(data[3], "Status");
            keyValuePairs.Add("[Status]", status);
        }
        var user = await _identityService.GetUser(_httpContext.HttpContext);

        // Only add comment if it exists
        if (!string.IsNullOrWhiteSpace(model.Comment))
        {
            keyValuePairs.Add("[Comment]", model.Comment);
            keyValuePairs.Add("[LatestCommentBy]", user.FirstName + " " + user.LastName);
        }

        result.Email.EmailBody = Template.Populate(result.Email.EmailBody, keyValuePairs);
        return result;

    }

    public async Task<ETDBResult> Op_10(ETDBProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(10, model);
    }

    public async Task<ETDBResult> Op_09(ETDBProcedure model = null)
    {
        var result = new ETDBResult();
        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(9));
        result.Data1 = data[0]; // Scoping Sheets
        result.Data2 = data[1]; // Scope Details
        return result;
    }

    public async Task<ETDBResult> Op_08(ETDBProcedure model = null)
    {
        return await ExecuteReader<SC>(8, model);
    }

    public async Task<ETDBResult> Op_07(ETDBProcedure model = null)
    {
        return await ExecuteReader<SC>(7, model);
    }

    public async Task<ETDBResult> Op_06(ETDBProcedure model = null)
    {
        return await ExecuteReader<SC>(6, model);
    }

    public async Task<ETDBResult> Op_05(ETDBProcedure model = null)
    {
        var sdTable = new TableType<SDTable>(model.Value2);
        var parameters = model.GetParameters(5)
        .AddParameter("@Detail", System.Data.SqlDbType.Structured, sdTable);
        var result = new ETDBResult();
        result.Data1 = await _sc.ExecuteReaderAsync(Query, parameters);

        return result;
    }

    public async Task<ETDBResult> Op_04(ETDBProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(4, model);
    }

    public async Task<ETDBResult> Op_03(ETDBProcedure model = null)
    {
        return await ExecuteNonQuery<SC>(3, model);
    }

    public async Task<ETDBResult> Op_02(ETDBProcedure model = null)
    {
        var result = new ETDBResult();
        var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(2));
        result.Data1 = data[0]; // TDS List
        result.Data2 = data[1]; // Sheet Statuses
        result.Data3 = data[2]; // Detail States
        result.Data4 = data[3]; // Assignments
        return result;
    }

    public async Task<ETDBResult> Op_01(ETDBProcedure model = null)
    {
        var sdTable = new TableType<SDTable>(model.Value1);
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 1);
        parameters.AddParameter("@EmployeeID", System.Data.SqlDbType.Int, model.EmployeeID);
        parameters.AddParameter("@Value1", System.Data.SqlDbType.VarChar, model.TDS.ProjectID);
        parameters.AddParameter("@Value2", System.Data.SqlDbType.VarChar, model.TDS.Title);
        parameters.AddParameter("@Value8", System.Data.SqlDbType.VarChar, model.TDS.Description);
        parameters.AddParameter("@Value3", System.Data.SqlDbType.VarChar, model.TDS.Type);
        parameters.AddParameter("@Value4", System.Data.SqlDbType.VarChar, model.TDS.Group);
        parameters.AddParameter("@Value5", System.Data.SqlDbType.VarChar, model.TDS.CommitmentID);
        parameters.AddParameter("@Value6", System.Data.SqlDbType.VarChar, model.TDS.Initiator);
        parameters.AddParameter("@Date1", System.Data.SqlDbType.VarChar, model.TDS.NeedDate);
        parameters.AddParameter("@IsTrue1", System.Data.SqlDbType.Bit, model.TDS.External);
        parameters.AddParameter("@IsTrue2", System.Data.SqlDbType.Bit, model.TDS.Emergent);
        parameters.AddParameter("@Detail", System.Data.SqlDbType.Structured, sdTable);
        parameters.AddParameter("@PressureBoundaryReview", System.Data.SqlDbType.Bit, model.TDS.PressureBoundaryReview);

        // calculate estimated hours
        parameters.AddParameter("@Num1", System.Data.SqlDbType.Int, (sdTable.Rows.Count == 0 ? 1 : sdTable.Rows.Count) * 2);

        var result = new ETDBResult();
        var tds = await _sc.ExecuteReaderAsync(Query, parameters);
        result.Data = tds[0];
        return result;
    }

    public Task<ETDBResult> Op_30(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_29(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_28(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_27(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_26(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_25(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_24(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_23(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_22(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_21(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_20(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_19(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ETDBResult> Op_18(ETDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<ETDBResult> Op_17(ETDBProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 17);
        parameters.AddParameter("@Value1", System.Data.SqlDbType.VarChar, model.Value1);
        var result = new ETDBResult();
        result.Data1 = await _sc.ExecuteReaderAsync(Query, model.GetParameters(17));

        return result;
    }

    public async Task<ETDBResult> Op_16(ETDBProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 16);
        parameters.AddParameter("@Value1", System.Data.SqlDbType.VarChar, model.Value1);
        var result = new ETDBResult();
        result.Data1 = await _sc.ExecuteReaderAsync(Query, model.GetParameters(16));

        return result;
    }
}
