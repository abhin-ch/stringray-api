using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.VDU;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore;
using System;
using System.Threading.Tasks;
using System.Data;
using System.Collections.Generic;

using Microsoft.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Threading.Tasks;


namespace StingrayNET.Infrastructure.Repository.Modules;
public class VDURepository : BaseRepository<VDUResult>, IRepositoryM<VDUProcedure, VDUResult>
{

    protected override string Query => "stng.SP_VDU_CRUD";

    private readonly IEmailService _emailService;

    public VDURepository(IDatabase<DED> mssql,IEmailService emailService) : base(mssql)
    {
        _emailService = emailService;
    }

    public async Task<VDUResult> Op_01(VDUProcedure model = null)
    {

        return await ExecuteReader<DED>(1,model);
    }

    public async Task<VDUResult> Op_02(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<VDUResult> Op_03(VDUProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<VDUResult> Op_04(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<VDUResult> Op_05(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<VDUResult> Op_06(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<VDUResult> Op_07(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<VDUResult> Op_08(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(8);
    }

    public async Task<VDUResult> Op_09(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(9);
    }

    public async Task<VDUResult> Op_10(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(10);
    }

    public async Task<VDUResult> Op_11(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<VDUResult> Op_12(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<VDUResult> Op_13(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<VDUResult> Op_14(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<VDUResult> Op_15(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(15,model);
    }

    public async Task<VDUResult> Op_16(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(16);
    }

    public async Task<VDUResult> Op_17(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(17);
    }

    public async Task<VDUResult> Op_18(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(18);
    }

    public async Task<VDUResult> Op_19(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(19);
    }

    public async Task<VDUResult> Op_20(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(20);
    }

    public async Task<VDUResult> Op_21(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(21);
    }

    public async Task<VDUResult> Op_22(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(22,model);
    }
    
    public async Task<VDUResult> Op_23(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(23,model);
    }

    public async Task<VDUResult> Op_24(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(24,model);
    }

    public async Task<VDUResult> Op_25(VDUProcedure model = null)
    {
        List<SqlParameter> tempParameters = new List<SqlParameter>();
        tempParameters.AddParameter("@Operation", SqlDbType.TinyInt, 11);
        tempParameters.AddParameter("@ReportId", SqlDbType.TinyInt, model.ReportId);

        var result = new VDUResult();

        result.reportInfo = await _ded.ExecuteReaderDTAsync(Query, tempParameters);

        tempParameters = new List<SqlParameter>();
        tempParameters.AddParameter("@Operation", SqlDbType.TinyInt, 12);
        tempParameters.AddParameter("@ReportId", SqlDbType.TinyInt, model.ReportId);

        result.sheetSchema = await _ded.ExecuteReaderDTAsync(Query, tempParameters);

        tempParameters = new List<SqlParameter>();
        tempParameters.AddParameter("@Operation", SqlDbType.TinyInt, 13);
        tempParameters.AddParameter("@ReportId", SqlDbType.TinyInt, model.ReportId);

        result.columnSchema = await _ded.ExecuteReaderDTAsync(Query, tempParameters);

        tempParameters = new List<SqlParameter>();
        tempParameters.AddParameter("@Operation", SqlDbType.TinyInt, 14);
        tempParameters.AddParameter("@ReportId", SqlDbType.TinyInt, model.ReportId);

        result.ruleSchema = await _ded.ExecuteReaderDTAsync(Query, tempParameters);

        return result;
    }

    

    public async Task<VDUResult> Op_26(VDUProcedure model = null)
    {
        var result = await ExecuteReader<DED>(26,model);

        List<string> emailTo = new List<string>();
        string[] listToItem = DataParser.GetValueFromData<string>(result.Data1, @"ToUserEmail").Split(';');
        foreach (var item in listToItem)
        {
            emailTo.Add(item);
        }
            // emailTo.Add(listToItem);
        // emailTo.Add("ngoc.nguyen@brucepower.com");

        List<string> emailCC = new List<string>();
        string[] listCCItem = DataParser.GetValueFromData<string>(result.Data1, @"CCUserEmail").Split(';');
        foreach (var item in listCCItem)
        {
            emailCC.Add(item);
        }
        // emailCC.Add("ngoc.nguyen@brucepower.com");

        string emailBody = DataParser.GetValueFromData<string>(result.Data1, @"EmailBody");
        string emailSubject = DataParser.GetValueFromData<string>(result.Data1, @"EmailSubject");

        EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject, emailBody: emailBody, CCList: emailCC);
        if (emailBody != "" && emailTo != null){
            await _emailService.Send(template);
        }

        return result;
    }

    public async Task<VDUResult> Op_27(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(27);
    }

    public async Task<VDUResult> Op_28(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(28,model);
    }

    public async Task<VDUResult> Op_29(VDUProcedure model = null)
    {
        return await ExecuteReader<DED>(29,model);
    }

    public Task<VDUResult> Op_30(VDUProcedure model = null)
    {
        throw new NotImplementedException();
    }
}
