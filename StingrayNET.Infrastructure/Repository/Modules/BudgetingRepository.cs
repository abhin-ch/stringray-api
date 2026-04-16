using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Models;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Models.Common.ADF;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.CustomExceptions;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Linq;
using Microsoft.Extensions.Configuration;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class BudgetingRepository : BaseRepository<PCCResult>, IRepositoryXL<PCCProcedure, PCCResult>
{
    protected override string Query => "stng.SP_Budgeting_CRUD";
    private string QueryEmail => "stng.SP_Budgeting_Emails";
    string Query71 => "stng.SP_Budgeting_ChangeStatusValidation";

    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IADFService _adfService;
    private readonly IConfiguration _config;
    private readonly IBLOBServiceNew _blobService;

    public BudgetingRepository(IDatabase<DED> ded, IDatabase<SC> sc, IHttpContextAccessor httpContextAccessor, IADFService adfService, IConfiguration config, IBLOBServiceNew blobService, IEmailService emailService) : base(ded, sc)
    {
        _httpContextAccessor = httpContextAccessor;
        _adfService = adfService;
        _config = config;
        _blobService = blobService;
    }

    public async Task<PCCResult> Op_01(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }

    public async Task<PCCResult> Op_02(PCCProcedure model = null)
    {
        // Create PBRF
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<PCCResult> Op_03(PCCProcedure model = null)
    {
        PCCRecordTypeEnum option;
        Enum.TryParse<PCCRecordTypeEnum>(model.Value1, out option);
        switch (option)
        {
            case PCCRecordTypeEnum.PBRF:
                {
                    model.SubOp = 1;
                    break;
                }
            case PCCRecordTypeEnum.SDQ:
                {
                    model.SubOp = 2;
                    break;
                }
            case PCCRecordTypeEnum.DVN:
                {
                    model.SubOp = 3;
                    break;
                }
        }
        var hasOption = Enum.TryParse<PCCRecordTypeEnum>(model.Value2, out option);
        if (hasOption)
        {
            switch (option)
            {
                case PCCRecordTypeEnum.PBRF:
                    {
                        model.SubOp = 4;
                        break;
                    }
                case PCCRecordTypeEnum.SDQ:
                    {
                        model.SubOp = 5;
                        break;
                    }
                case PCCRecordTypeEnum.DVN:
                    {
                        model.SubOp = 5;
                        break;
                    }
            }
        }

        return await ExecuteReader<DED>(3, model);
    }

    public async Task<PCCResult> Op_04(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<PCCResult> Op_05(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(5, model);
    }

    public async Task<PCCResult> Op_06(PCCProcedure model = null)
    {
        model = new PCCProcedure()
        {
            EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
        };

        return await ExecuteReader<DED>(6, model);
    }

    public async Task<PCCResult> Op_07(PCCProcedure model = null)
    {
        if (model.SubOp == 4)
        {
            return await ExecuteReaderValidation<DED>(7, model);
        }
        return await ExecuteReader<DED>(7, model);

    }

    public async Task<PCCResult> Op_08(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<PCCResult> Op_09(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<PCCResult> Op_10(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<PCCResult> Op_11(PCCProcedure model = null)
    {
        //Get P6 Run ID
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        if (model.SubOp == 3)
        {
            return await ExecuteReaderValidation<DED>(11, model);
        }

        //Trigger ADF pipeline
        else if (model.SubOp == 4)
        {
            TriggerRequest request = new TriggerRequest(

                pipelineName: @"Budgeting_SDQ_P6Import",
                parameters: new Dictionary<string, object>()
                {
                        { @"ProjectID", model.ProjectID },
                        { @"RunID", model.P6RunID },
                        {@"Server", _config[@"MSSQL:DED:Server"]},
                         {@"Database", _config[@"MSSQL:DED:Database"]},
                },
                alwaysUseProduction: true
            );

            return new PCCResult() { Data = await _adfService.TriggerPipeline(request) };

        }

        // Reserved for polling ADF; no equivalent MSSQL operation
        else if (model.SubOp == 25)
        {
            var adfStatus = await _adfService.PollPipeline(model.PipelineID, true);

            if (!adfStatus.active)
            {
                //Post-process P6 data pull to obtain PhaseCode and DisciplineCode
                List<SqlParameter> parameters = new List<SqlParameter>()
                    {
                        new SqlParameter()
                        {
                            ParameterName = @"@Operation",
                            SqlDbType = SqlDbType.Int,
                            Value = 11
                        },
                        new SqlParameter()
                        {
                            ParameterName = @"@SubOp",
                            SqlDbType = SqlDbType.Int,
                            Value = 4
                        },
                        new SqlParameter()
                        {
                            ParameterName = @"@P6RunID",
                            SqlDbType = SqlDbType.VarChar,
                            Value = model.P6RunID
                        },
                        new SqlParameter()
                        {
                            ParameterName = @"@EmployeeID",
                            SqlDbType = SqlDbType.VarChar,
                            Value = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
                        },
                        new SqlParameter()
                        {
                            ParameterName = @"@SDQID",
                            SqlDbType = SqlDbType.BigInt,
                            Value = model.SDQID
                        }
                    };

                DataTable dt = await _ded.ExecuteReaderDTAsync(Query, parameters);

                if (dt.Rows.Count == 0)
                {
                    throw new Exception(@"No P6 information obtainable for specified RunID");
                }

                DataTable dtOutput = new DataTable();
                dtOutput.Columns.Add(new DataColumn(@"Task_ID", typeof(string)));
                dtOutput.Columns.Add(new DataColumn(@"PhaseCode", typeof(int)));
                dtOutput.Columns.Add(new DataColumn(@"DisciplineCode", typeof(int)));
                dtOutput.Columns.Add(new DataColumn(@"UniqueID", typeof(int)));

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string uniqueID = dt.Rows[i][@"UniqueID"].ToString();
                    string task_id = dt.Rows[i][@"task_id"].ToString();
                    string wbsCode = dt.Rows[i][@"wbs_code"].ToString();
                    int wbsLvl = Convert.ToInt32(dt.Rows[i][@"wbs_lvl"]);

                    if (Regex.IsMatch(wbsCode, @"^[0-9]") && wbsLvl >= 4)
                    {
                        var parts = wbsCode.Split('.');
                        if (parts.Length >= 3 &&
                            int.TryParse(parts[1], out int code) &&
                            int.TryParse(parts[2], out int rawPhaseCode))
                        {
                            var newRow = dtOutput.NewRow();

                            // Determine PhaseCode based on 'code' and 'rawPhaseCode'
                            int? phaseCode = null;

                            if (code == 1)
                            {
                                phaseCode = rawPhaseCode;
                            }
                            else if (code == 6)
                            {
                                switch (rawPhaseCode)
                                {
                                    case 1:
                                        phaseCode = 1;
                                        break;
                                    case 2:
                                    case 3:
                                    case 4:
                                    case 5:
                                        phaseCode = rawPhaseCode - 1;
                                        break;
                                    case 6:
                                        phaseCode = 4;
                                        break;
                                    case 7:
                                        phaseCode = 5;
                                        break;
                                }
                            }

                            if (phaseCode.HasValue)
                            {
                                newRow["PhaseCode"] = phaseCode.Value;
                            }

                            if (parts.Length >= 4 && int.TryParse(parts[3], out int disciplineCode))
                            {
                                newRow["DisciplineCode"] = disciplineCode;
                            }

                            if (string.IsNullOrEmpty(task_id))
                            {
                                if (int.TryParse(uniqueID, out int id))
                                {
                                    newRow["UniqueID"] = id;
                                }

                            }
                            else
                            {
                                newRow["Task_ID"] = task_id;
                            }

                            dtOutput.Rows.Add(newRow);
                        }
                        else
                        {
                            Console.WriteLine($"Invalid WBS format or parsing failed: {wbsCode}");
                        }
                    }
                }

                if (dtOutput.Rows.Count > 0)
                {
                    parameters = new List<SqlParameter>()
                        {
                            new SqlParameter()
                            {
                                ParameterName = @"@Operation",
                                SqlDbType = SqlDbType.Int,
                                Value = 11
                            },
                            new SqlParameter()
                            {
                                ParameterName = @"@SubOp",
                                SqlDbType = SqlDbType.Int,
                                Value = 5
                            },
                            new SqlParameter()
                            {
                                ParameterName = @"@P6RunID",
                                SqlDbType = SqlDbType.VarChar,
                                Value = model.P6RunID
                            },
                            new SqlParameter()
                            {
                                ParameterName = @"@SDQID",
                                SqlDbType = SqlDbType.BigInt,
                                Value = model.SDQID
                            },
                            new SqlParameter()
                            {
                                ParameterName = @"@EmployeeID",
                                SqlDbType = SqlDbType.VarChar,
                                Value = model.EmployeeID
                            },
                            new SqlParameter()
                            {
                                ParameterName = @"@P6PostProcess",
                                SqlDbType = SqlDbType.Structured,
                                Value = dtOutput
                            }
                        };

                    var dbReturn2 = await _ded.ExecuteReaderAsync(Query, parameters);

                    if (dbReturn2.Count > 0)
                    {
                        var firstResult = dbReturn2.Select((x) => (Dictionary<string, object>)x).FirstOrDefault();

                        if (firstResult.ContainsKey(@"ReturnMessage"))
                        {
                            throw new ValidationException(firstResult[@"ReturnMessage"].ToString());
                        }
                    }
                }

                //Do P6 Validation Checks
                model.SubOp = 26;
                var p6ValidationResult = await ExecuteReaderValidation<DED>(11, model);

                if (p6ValidationResult.Data1.Count > 0)
                {
                    return new PCCResult() { Data = @"Complete", HasP6Error = true };
                }

                else
                {
                    return new PCCResult() { Data = @"Complete", HasP6Error = false };
                }

            }

            else
            {
                return new PCCResult() { Data = @"In Progress" };
            }
        }
        else if (model.SubOp == 26)
        {
            return await ExecuteReader<DED>(11, model);
        }

        else if (model.SubOp != 5 && model.SubOp != 26) // 5 is a conjunctive subop to Subop 4, 26 is a conjunctive subop to SubOp 25
        {
            return await ExecuteReaderValidation<DED>(11, model);
        }

        else
        {
            throw new NotImplementedException();
        }

    }

    public async Task<PCCResult> Op_12(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(12, model);
    }

    public async Task<PCCResult> Op_13(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<PCCResult> Op_14(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(14);
    }

    public async Task<PCCResult> Op_15(PCCProcedure model = null)
    {
        int operation = 0;
        switch (Enum.Parse<DEDStatusEnum>(model.Value1))
        {
            case DEDStatusEnum.AOEFR:
                {
                    operation = 1;
                    break;
                }
            case DEDStatusEnum.INIT:
            case DEDStatusEnum.CORR:
                {
                    operation = 2;
                    break;
                }
            case DEDStatusEnum.AVER:
                {
                    operation = 3;
                    break;
                }
            case DEDStatusEnum.APJMA:
                {
                    operation = 4;
                    break;
                }
            case DEDStatusEnum.AEBSP:
            case DEDStatusEnum.AAEBS:
                {
                    operation = 5;
                    break;
                }

            default:
                throw new Exception($"BudgetingRepository:Op_15 - FromStatusCode ({model.Value1}) not configured for validation");


        }
        return await ExecuteReader<DED>(operation, model, "stng.SP_Budgeting_ChangeStatusValidation");
    }

    public async Task<PCCResult> Op_16(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<PCCResult> Op_17(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<PCCResult> Op_18(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<PCCResult> Op_19(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = await ExecuteReaderValidation<DED>(19, model);

        return result;
    }

    public async Task<PCCResult> Op_20(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<PCCResult> Op_21(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(21, model);
    }

    public async Task<PCCResult> Op_22(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(22);
    }

    public async Task<PCCResult> Op_23(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<PCCResult> Op_24(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<PCCResult> Op_25(PCCProcedure model = null)
    {
        // Not in use
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<PCCResult> Op_26(PCCProcedure model = null)
    {
        // Not in use
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<PCCResult> Op_27(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<PCCResult> Op_28(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public Task<PCCResult> Op_29(PCCProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<PCCResult> Op_30(PCCProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<PCCResult> Op_45(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(45, model);
    }
    public async Task<PCCResult> Op_44(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(44, model);
    }
    public async Task<PCCResult> Op_43(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(43);
    }
    public async Task<PCCResult> Op_42(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(42, model);
    }
    public async Task<PCCResult> Op_41(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(41, model);
    }
    public async Task<PCCResult> Op_40(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(40, model);
    }
    public async Task<PCCResult> Op_39(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(39, model);
    }

    public async Task<PCCResult> Op_38(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(38, model);
    }
    public async Task<PCCResult> Op_37(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(37, model);
    }
    public async Task<PCCResult> Op_36(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(36, model);
    }
    public async Task<PCCResult> Op_35(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(35, model);
    }
    public async Task<PCCResult> Op_34(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(34, model);
    }
    public async Task<PCCResult> Op_33(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(33, model);
    }
    public async Task<PCCResult> Op_32(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(32, model);
    }
    public async Task<PCCResult> Op_31(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model, QueryEmail);
    }

    public async Task<PCCResult> Op_61(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(61, model);
    }
    public async Task<PCCResult> Op_62(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(62, model);
    }
    public async Task<PCCResult> Op_63(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(63, model);
    }
    public async Task<PCCResult> Op_64(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(64, model);
    }
    public async Task<PCCResult> Op_65(PCCProcedure model = null)
    {
        //Do RSS here

        await _blobService.Upload(_httpContextAccessor.HttpContext, @"PCC", Department.DED, true);

        return new PCCResult();
    }
    public async Task<PCCResult> Op_66(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(66, model);
    }
    public async Task<PCCResult> Op_67(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(67, model);
    }
    public async Task<PCCResult> Op_68(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(68, model);
    }
    public async Task<PCCResult> Op_69(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(69, model);
    }
    public async Task<PCCResult> Op_70(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(70, model);
    }
    public async Task<PCCResult> Op_71(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(71, model);
    }
    public async Task<PCCResult> Op_72(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(72, model);
    }
    public async Task<PCCResult> Op_73(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(73, model);
    }
    public async Task<PCCResult> Op_74(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(74, model);
    }
    public async Task<PCCResult> Op_75(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(75, model);
    }
    public async Task<PCCResult> Op_76(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(76, model);
    }
    public async Task<PCCResult> Op_77(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_78(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_79(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_80(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_81(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_82(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_83(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_84(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_85(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_86(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_87(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_88(PCCProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PCCResult> Op_89(PCCProcedure model = null) { throw new NotImplementedException(); }

    public async Task<PCCResult> Op_90(PCCProcedure model = null)
    {
        return await ExecuteReader<DED>(90, model);
    }
    public async Task<PCCResult> Op_60(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(60, model);
    }
    public async Task<PCCResult> Op_59(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(59, model);
    }
    public async Task<PCCResult> Op_58(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(58, model);
    }
    public async Task<PCCResult> Op_57(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(57, model);
    }
    public async Task<PCCResult> Op_56(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(56, model);
    }
    public async Task<PCCResult> Op_55(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(55, model);
    }
    public async Task<PCCResult> Op_54(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(54, model);
    }
    public async Task<PCCResult> Op_53(PCCProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(53, model);
    }
    public async Task<PCCResult> Op_52(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(52, model);
    }
    public async Task<PCCResult> Op_51(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(51, model);
    }
    public async Task<PCCResult> Op_50(PCCProcedure model = null)
    {
        var adfStatus = await _adfService.PollPipeline(model.PipelineID, true);

        if (!adfStatus.active)
        {
            return new PCCResult() { Data = @"Complete" };
        }

        else
        {
            return new PCCResult() { Data = @"In Progress" };
        }
    }
    public async Task<PCCResult> Op_49(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(49, model);
    }
    public async Task<PCCResult> Op_48(PCCProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(48, model);
    }
    public async Task<PCCResult> Op_47(PCCProcedure model = null)
    {
        TriggerRequest request = new TriggerRequest(

                pipelineName: @"PCC_Forecast",
                parameters: new Dictionary<string, object>()
                {
                        { @"UUID", model.ForecastUUID },
                        {@"BLOBEndpoint",_config[@"Storage:ServiceUri"]},
                        {@"Server", _config[@"MSSQL:DED:Server"]},
                         {@"Database", _config[@"MSSQL:DED:Database"]},
                },
                alwaysUseProduction: true
            );

        return new PCCResult() { Data = await _adfService.TriggerPipeline(request) };
    }
    public async Task<PCCResult> Op_46(PCCProcedure model = null)
    {
        //Do RSS here

        await _blobService.Upload(_httpContextAccessor.HttpContext, @"PCC", Department.DED);

        return new PCCResult();
    }

}