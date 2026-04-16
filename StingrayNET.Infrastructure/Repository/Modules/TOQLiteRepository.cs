using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.TOQLite;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;
using System.Linq;
using Microsoft.Extensions.Configuration;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.Infrastructure.Repository.Modules;

public class TOQLiteRepository : BaseRepository<TOQLiteResult>, IRepositoryXL<TOQLiteProcedure, TOQLiteResult>
{
    protected override string Query => "stng.SP_TOQLite_CRUD";
    private IHttpContextAccessor _httpContextAccessor;
    private readonly IConfiguration _config;
    public TOQLiteRepository(IDatabase<DED> mssql, IDatabase<SC> scsql, IHttpContextAccessor httpContextAccessor,
    IIdentityService identityService, IConfiguration config) : base(mssql, scsql)
    {
        _httpContextAccessor = httpContextAccessor;
        _config = config;
    }

    //TODO - centralize this logic in new User Mgmt
    //TODO - allow for multivendor (Currently just single vendor)
    public async Task<TOQLiteResult> Op_01(TOQLiteProcedure model = null)
    {

        var scModel = new AdminProcedure
        {
            EmployeeID = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()),
            Permission = "SeeAllTOQLiteRecords"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            model.SeeAll = true;

        }
        else
        {
            model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString());

        }


        return await ExecuteReader<DED>(1, model);
    }

    public async Task<TOQLiteResult> Op_02(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(2);
    }

    public async Task<TOQLiteResult> Op_03(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<TOQLiteResult> Op_04(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<TOQLiteResult> Op_05(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(5);
    }

    public async Task<TOQLiteResult> Op_06(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<TOQLiteResult> Op_07(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<TOQLiteResult> Op_08(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<TOQLiteResult> Op_09(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(9, model);
    }

    public async Task<TOQLiteResult> Op_10(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();

        return await ExecuteReader<DED>(10, model);
    }

    public async Task<TOQLiteResult> Op_11(TOQLiteProcedure model = null)
    {

        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var firstResultEither = await ExecuteReaderValidation<DED>(11, model);

        if (firstResultEither.Data1.Count > 0)
        {
            Dictionary<string, object> firstResultData = (Dictionary<string, object>)firstResultEither.Data1[0];

            model.FromERModule = true;
            model.TOQLiteID = firstResultData[@"TOQLiteID"].ToString();

            await ExecuteNonQuery<DED>(10, model);

        }

        return firstResultEither;

    }

    public async Task<TOQLiteResult> Op_12(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(12, model);
    }

    public async Task<TOQLiteResult> Op_13(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(13, model);
    }

    public async Task<TOQLiteResult> Op_14(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(14, model);
    }

    public async Task<TOQLiteResult> Op_15(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(15, model);
    }

    public async Task<TOQLiteResult> Op_16(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<TOQLiteResult> Op_17(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<TOQLiteResult> Op_18(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<TOQLiteResult> Op_19(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<TOQLiteResult> Op_20(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(20, model);
    }

    public async Task<TOQLiteResult> Op_21(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(21, model);
    }

    public async Task<TOQLiteResult> Op_22(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(22, model);
    }

    public async Task<TOQLiteResult> Op_23(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(23, model);
    }

    public async Task<TOQLiteResult> Op_24(TOQLiteProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(24, model);
    }

    public async Task<TOQLiteResult> Op_25(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<TOQLiteResult> Op_26(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(26, model);
    }

    public async Task<TOQLiteResult> Op_27(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(27, model);
    }

    public async Task<TOQLiteResult> Op_28(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(28);
    }

    public async Task<TOQLiteResult> Op_29(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(29, model);
    }

    public async Task<TOQLiteResult> Op_30(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(30);
    }

    public async Task<TOQLiteResult> Op_45(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(45, model);
    }

    public async Task<TOQLiteResult> Op_44(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(44, model);
    }

    public async Task<TOQLiteResult> Op_43(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(43, model);
    }

    public async Task<TOQLiteResult> Op_42(TOQLiteProcedure model = null)
    {
        var result = new TOQLiteResult();
        result.Email = new TOQLiteResult.EmailResult();

        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        string currentStatus = model.CurrentStatus;
        string nextStatus = model.StatusShort;

        //Get Vendor and SM emails and email template data (subject and body)
        var data = await _ded.ExecuteReaderSetAsync(Query, model.GetParameters(42));

        var vendorEmails = DataParser.GetListFromData(data[0], "Email");
        var smEmails = DataParser.GetListFromData(data[1], "Email");

        var er = DataParser.GetValueFromData<string>(data[2], "ER");
        var vendorResponseDate = DataParser.GetValueFromData<string>(data[2], "VendorResponseDate");
        DateTime parsedDate;
        string formattedDate;
        bool parseSuccess = DateTime.TryParse(vendorResponseDate, out parsedDate);

        if (!parseSuccess)
        {
            formattedDate = null;
        }
        else
        {
            formattedDate = parsedDate.ToString("dd MMM yyyy");
        }

        var vendor = DataParser.GetValueFromData<string>(data[2], "Vendor");

        var emailSubject = DataParser.GetValueFromData<string>(data[3], "Subject");
        var emailBody = DataParser.GetValueFromData<string>(data[3], "Body");

        if (emailSubject == null || emailBody == null)
        {
            throw new Exception("There is no valid email template to use, check current status and next status states and compare to mapping table.");
        }

        //Get emails of users with the TOQLiteERSPOCEmail permission

        var scModel = new Procedure { Value1 = "TOQLiteERSPOCEmail" };
        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserAccessWeb", scModel.GetParameters(36));
        List<string> permissionEmails = new List<string> { };

        foreach (var obj in db[0])
        {
            if (obj is Dictionary<string, object> dict)
            {
                if (dict.TryGetValue("Email", out object value))
                {

                    if (value is string stringValue)
                    {
                        permissionEmails.Add(stringValue);
                    }

                }
            }
        }

        var request = _httpContextAccessor.HttpContext.Request;
        string scheme = request.Scheme;
        string domain = request.Host.Host;
        string deepLink = string.Format("{0}/toq-lite?ID={1}", _config["FEURL"], model.TOQLiteID);

        result.Email.To = new List<string> { };
        result.Email.CC = new List<string> { };

        if (currentStatus == "I" && nextStatus == "AV")
        {
            result.Email.To.AddRange(vendorEmails);
            result.Email.CC.AddRange(smEmails);
            result.Email.CC.AddRange(permissionEmails);
        }
        else if (currentStatus == "AV" && nextStatus == "AB")
        {
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
            result.Email.CC.AddRange(vendorEmails);
        }
        else if (currentStatus == "AB" && nextStatus == "AA")
        {
            result.Email.To.AddRange(vendorEmails);
            result.Email.CC.AddRange(smEmails);
            result.Email.CC.AddRange(permissionEmails);
        }
        else if (currentStatus == "AB" && nextStatus == "AV")
        {
            result.Email.To.AddRange(vendorEmails);
            result.Email.CC.AddRange(smEmails);
            result.Email.CC.AddRange(permissionEmails);
        }
        else if (currentStatus == "AB" && nextStatus == "I")
        {
            result.Email.To.AddRange(vendorEmails);
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
        }
        else if (currentStatus == "AB" && nextStatus == "C")
        {
            result.Email.To.AddRange(vendorEmails);
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
        }
        else if (currentStatus == "I" && nextStatus == "C")
        {
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
        }
        else if (currentStatus == "AV" && nextStatus == "NB")
        {
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
            result.Email.CC.AddRange(vendorEmails);
        }
        else if (currentStatus == "NB" && nextStatus == "I")
        {
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
        }
        else if (currentStatus == "NB" && nextStatus == "C")
        {
            result.Email.To.AddRange(smEmails);
            result.Email.To.AddRange(permissionEmails);
        }
        else
        {
            throw new Exception("No email template data.");
        }


        var keyValuePairs = new Dictionary<string, string>();

        keyValuePairs.Add("[ER]", er);
        keyValuePairs.Add("[VendorResponseDate]", formattedDate);
        keyValuePairs.Add("[Vendor]", vendor);
        keyValuePairs.Add("[Comment]", model.Comment);
        keyValuePairs.Add("[DeepLink]", deepLink);

        result.Email.EmailBody = Template.Populate(emailBody, keyValuePairs);
        result.Email.Subject = Template.Populate(emailSubject, keyValuePairs);

        result.Email.To = result.Email.To?
        .Where(e => !string.IsNullOrEmpty(e))
        .Select(e => e.ToLower())
        .Distinct().ToList();

        result.Email.CC = result.Email.CC?
        .Where(e => !string.IsNullOrEmpty(e))
        .Select(e => e.ToLower())
        .Distinct().ToList();

        return result;
    }

    public async Task<TOQLiteResult> Op_41(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteNonQuery<DED>(41, model);
    }

    public async Task<TOQLiteResult> Op_40(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(40, model);
    }

    public async Task<TOQLiteResult> Op_39(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(39, model);
    }

    public async Task<TOQLiteResult> Op_38(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(38, model);
    }

    public async Task<TOQLiteResult> Op_37(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(37, model);
    }

    public async Task<TOQLiteResult> Op_36(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(36, model);
    }

    public async Task<TOQLiteResult> Op_35(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(35, model);
    }

    public async Task<TOQLiteResult> Op_34(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(34, model);
    }

    public async Task<TOQLiteResult> Op_33(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(33, model);
    }

    public async Task<TOQLiteResult> Op_32(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(32, model);
    }

    public async Task<TOQLiteResult> Op_31(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(31, model);
    }

    public Task<TOQLiteResult> Op_60(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_59(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_58(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_57(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_56(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_55(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_54(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_53(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_52(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_51(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQLiteResult> Op_50(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<TOQLiteResult> Op_49(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(49, model);
    }

    public async Task<TOQLiteResult> Op_48(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(48, model);
    }

    public async Task<TOQLiteResult> Op_47(TOQLiteProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var result = new TOQLiteResult();

        foreach (var qualification in model.Qualifications)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 47);
            parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 1);
            parameters.AddParameter("@TOQLiteID", SqlDbType.UniqueIdentifier, Guid.Parse(model.TOQLiteID));
            parameters.AddParameter("@Qualification", SqlDbType.UniqueIdentifier, Guid.Parse(qualification.id));

            List<object> categories = await _ded.ExecuteReaderAsync(Query, parameters);
            if ((qualification.value && categories.Count > 0) || (!qualification.value && categories.Count == 0))
            {
                continue;
            }
            else if (qualification.value)
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 47);
                parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 2);
                parameters.AddParameter("@TOQLiteID", SqlDbType.UniqueIdentifier, Guid.Parse(model.TOQLiteID));
                parameters.AddParameter("@Qualification", SqlDbType.UniqueIdentifier, Guid.Parse(qualification.id));
                parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
            else
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 47);
                parameters.AddParameter("@SubOp", SqlDbType.TinyInt, 3);
                parameters.AddParameter("@TOQLiteID", SqlDbType.UniqueIdentifier, Guid.Parse(model.TOQLiteID));
                parameters.AddParameter("@Qualification", SqlDbType.UniqueIdentifier, Guid.Parse(qualification.id));

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
        }

        return result;
    }

    public async Task<TOQLiteResult> Op_46(TOQLiteProcedure model = null)
    {
        return await ExecuteReader<DED>(46, model);
    }

    public Task<TOQLiteResult> Op_61(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_62(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_63(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_64(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_65(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_66(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_67(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_68(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_69(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_70(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_71(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_72(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_73(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_74(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_75(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_76(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_77(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_78(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_79(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_80(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_81(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_82(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_83(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_84(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_85(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_86(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_87(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_88(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_89(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public Task<TOQLiteResult> Op_90(TOQLiteProcedure model = null)
    {
        throw new NotImplementedException();
    }
}