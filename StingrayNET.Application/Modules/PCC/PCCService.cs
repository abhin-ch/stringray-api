using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.Office.Interop.Excel;
using StingrayNET.Application.Modules.PCC.Workflow;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.Models.PCC.PBRF;
using StingrayNET.ApplicationCore.Models.PCC.SDQ;
using StingrayNET.ApplicationCore.Requests.PCC;
using s = Serilog;
using System.Diagnostics;


namespace StingrayNET.Application.Modules.PCC;

public interface IPCCService
{
    Task<PCCResult> GetPCCMain(PCCGetPCCMainRequest request);
    Task GetUIAccess(PCCProcedure model);
    Task<List<BaseStatus<PCCModel>>> GetStatusOptions(PCCStatusOptionsRequest request);
    Task<PCCResult> GetDropdownOptions(int operation);
    Task<bool> GetTabVisibility(PCCTabVisibilityRequest request);
    Task<string> UpdateStatus(PCCUpdateStatusRequest request);
    Task<PCCResult> InitPBRF(PCCProcedure model);
    Task<(bool, string)> UpdateStatusValidation(PCCUpdateStatusValidationRequest request);
    Task<(bool, List<string>)> ValidatePBRFHeader(int uniqueID);
    Task UpdateStatusDVN(PCCProcedure request);
    Task<Dictionary<string, object>> GetSDQPDFReport(int SDQUID);
    Task<PCCResult> P6Run(PCCProcedure request);

    // List<BaseStatus<T>> GetPCCStatusOptions<T>(T model) where T : BasePCCModel
}

public class PCCService : IPCCService
{
    private IRepositoryXL<PCCProcedure, PCCResult> _repository;
    private readonly IPCCStatusProvider _statusProvider;
    private readonly IPCCHelperFunctions _helperFunctions;
    private readonly s.ILogger _logger;
    private readonly IPCCSingletonService _singletonService;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public PCCService(IRepositoryXL<PCCProcedure, PCCResult> repository, IHttpContextAccessor httpContextAccessor, IPCCStatusProvider statusProvider,
     IPCCHelperFunctions helperFunctions, IPCCSingletonService singletonService, s.ILogger logger)
    {
        _repository = repository;
        _statusProvider = statusProvider;
        _helperFunctions = helperFunctions;
        _singletonService = singletonService;
        _httpContextAccessor = httpContextAccessor;
        _logger = logger;
    }

    public async Task GetUIAccess(PCCProcedure model)
    {
        var result = await _repository.Op_49(model);
        var sdq = result;

    }

    public async Task<List<BaseStatus<PCCModel>>> GetStatusOptions(PCCStatusOptionsRequest request)
    {
        var pccModel = await _statusProvider.CreateModel(request);
        pccModel.User = await _helperFunctions.GetUserRole(request.EmployeeID);
        var result = await _statusProvider.GetPCCStatusOptions(pccModel);
        return result;

    }

    public async Task<bool> GetTabVisibility(PCCTabVisibilityRequest request)
    {
        switch (request.TabName)
        {
            case "PBRFHeader":
                {
                    break;
                }
            case "SDQHeader":
                {
                    break;
                }
            case "DVNHeader":
                {
                    break;
                }
            case "RelatedTOQ":
                {
                    break;
                }
            case "P6":
                {
                    break;
                }
            case "SelfCheck":
                {
                    break;
                }
            case "Verification":
                {
                    break;
                }
            case "PlannerCheck":
                {
                    break;
                }
            case "SMApproval":
                {
                    break;
                }
            case "CustomerApproval":
                {
                    break;
                }
            case "RevisedCommitments":
                {
                    break;
                }
            case "FundingAllocation":
                {
                    break;
                }
            case "StatusLog":
                {
                    break;
                }
            case "MinorChange":
                {
                    break;
                }
            default:
                {
                    throw new ArgumentException($"Tab name: {request.TabName} DNE.");
                }
        }

        return false;

    }

    public async Task<bool> SendEmail(PCCEmailModel model)
    {
        User? originalUser = (User)_httpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"];
        bool impersonating = _httpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS");

        await _singletonService.SendEmail(model, originalUser, impersonating);

        return true;
    }

    public async Task UpdateStatusDVN(PCCProcedure model)
    {
        //Update status 
        await _repository.Op_39(model);

        //Send Email
        var emailModel = new PCCEmailModel();
        emailModel.Value1 = model.DVNID?.ToString();//UUID
        emailModel.Value2 = model.NextStatus;
        emailModel.RecordType = @"DVN";
        emailModel.EmployeeID = model.EmployeeID;

        await SendEmail(emailModel);
    }
    public async Task<PCCResult> InitPBRF(PCCProcedure model)
    {



        var result = new PCCResult();

        // Revising PBRF
        if (model.Num1 > 0)
        {
            model.RecordType = "PBRF";
            model.NextStatus = "SUPER";
            model.PBRID = model.Num1;
            result = await _repository.Op_12(model);
        }
        else
        {
            //Create PBRF
            result = await _repository.Op_02(model);
        }
        var primaryKey = DataParser.GetValueFromData<string>(result.Data1, "PrimaryKey")?.Remove(0, 5);

        //Send email
        var emailModel = new PCCEmailModel();
        emailModel.Value1 = primaryKey;
        emailModel.RecordType = "PBRF";
        emailModel.Value2 = "INIT";
        emailModel.EmployeeID = model.EmployeeID;

        await SendEmail(emailModel);

        return result;
    }

    public async Task<string> UpdateStatus(PCCUpdateStatusRequest request)
    {
        var model = new PCCProcedure
        {
            SDQID = request.ID,
            PBRID = request.ID,
            NextStatus = request.NextStatus,
            RecordType = request.RecordType,
            EmployeeID = request.EmployeeID,
            Comment = request.Comment
        };
        var result = await _repository.Op_12(model);

        var emailModel = new PCCEmailModel();
        emailModel.Value1 = request.ID.ToString();
        emailModel.RecordType = model.RecordType;
        emailModel.Value2 = model.NextStatus;
        emailModel.EmployeeID = model.EmployeeID;

        //Don't send email on revision
        if (!(model.NextStatus.ToUpper() == "SUPER" && model.RecordType.ToUpper() == "PBRF"))
        {
            await SendEmail(emailModel);
        }

        //send additional email to this address in certain cases
        switch (model.NextStatus)
        {
            case "AFRE":
            case "APRE":
            case "AOEFR":
            case "APCSC":
            case "AOERC":
                {

                    var bnpdEmail = new PCCEmailModel();
                    bnpdEmail.Value1 = request.ID.ToString();
                    bnpdEmail.Value2 = "BNPD";
                    bnpdEmail.RecordType = model.RecordType;
                    bnpdEmail.EmployeeID = model.EmployeeID;

                    await SendEmail(bnpdEmail);
                    break;
                }
        }

        //logic for late start additional emails
        if (model.NextStatus != null && model.RecordType.Equals("SDQ"))
        {
            var lateStartEmail = new PCCEmailModel();
            lateStartEmail.Value1 = model.Value1;
            lateStartEmail.RecordType = model.RecordType;
            bool sendEmail = false;
            switch (model.NextStatus)
            {
                case "AOERC":
                    {
                        lateStartEmail.Value2 = "AOERCLS";
                        sendEmail = true;
                        break;
                    }
                case "APCSC":
                    {
                        lateStartEmail.Value2 = "AOERCLS";
                        sendEmail = true;
                        break;
                    }
                case "AOEFR":
                    {
                        lateStartEmail.Value2 = "AOEFRLS";
                        sendEmail = true;
                        break;
                    }
            }

            if (sendEmail)
            {
                await SendEmail(lateStartEmail);
            }
        }
        return string.Empty;
    }

    public async Task<(bool, string)> UpdateStatusValidation(PCCUpdateStatusValidationRequest request)
    {
        var model = new PCCProcedure
        {
            RecordType = request.RecordType,
            RecordUID = request.RecordUID,
            NextStatus = request.NextStatus,
            EmployeeID = request.EmployeeID,
            Value1 = request.CurrentStatus
        };
        try
        {
            var result = await _repository.Op_71(model);
            switch (request.CurrentStatus)
            {
                case "INIT":
                    {
                        var isP6Linked = DataParser.GetListFromData<bool>(result.Data1, "Active");
                        if (!isP6Linked.Contains(true))
                            return (false, "P6 Schedule not linked");
                        // check for self checklist is complete
                        var categories = DataParser.GetListFromData<string>(result.Data2, "QuestionCategory");
                        var questions = DataParser.GetListFromData<string>(result.Data2, "QuestionOrder");

                        // pair category + order together
                        var pairs = categories.Zip(questions, (cat, ord) => new { Category = cat, Order = ord })
                                              .Where(x => !string.IsNullOrWhiteSpace(x.Category) && !string.IsNullOrWhiteSpace(x.Order))
                                              .GroupBy(x => x.Category)
                                              .Select(g => $"( {g.Key} : {string.Join(", ", g.Select(x => x.Order))} )");

                        if (pairs.Any())
                        {
                            var groupedString = string.Join(", ", pairs);
                            return (false, $"Self-Check CheckList is incomplete. Questions under sections {groupedString}. Must include a comment for responses marked No or N/A.");
                        }
                        break;
                    }

                case "AOEA":
                    {
                        // check for OEL checklist is complete
                        var categories = DataParser.GetListFromData<string>(result.Data1, "QuestionCategory");
                        var questions = DataParser.GetListFromData<string>(result.Data1, "QuestionOrder");

                        // pair category + order together
                        var pairs = categories.Zip(questions, (cat, ord) => new { Category = cat, Order = ord })
                                              .Where(x => !string.IsNullOrWhiteSpace(x.Category) && !string.IsNullOrWhiteSpace(x.Order))
                                              .GroupBy(x => x.Category)
                                              .Select(g => $"( {g.Key} : {string.Join(", ", g.Select(x => x.Order))} )");

                        if (pairs.Any())
                        {
                            var groupedString = string.Join(", ", pairs);
                            return (false, $"OEL CheckList is incomplete. Questions under sections {groupedString}. Must include a comment for responses marked No or N/A.");
                        }
                        break;
                    }

                case "AVER":
                    {
                        // check for verification checklist is complete
                        var Verificationcategories = DataParser.GetListFromData<string>(result.Data1, "QuestionCategory");
                        var Verificationquestions = DataParser.GetListFromData<string>(result.Data1, "QuestionOrder");

                        // pair category + order together
                        var Verificationpairs = Verificationcategories.Zip(Verificationquestions, (cat, ord) => new { Category = cat, Order = ord })
                                              .Where(x => !string.IsNullOrWhiteSpace(x.Category) && !string.IsNullOrWhiteSpace(x.Order))
                                              .GroupBy(x => x.Category)
                                              .Select(g => $"( {g.Key} : {string.Join(", ", g.Select(x => x.Order))} )");

                        if (Verificationpairs.Any())
                        {
                            var groupedString = string.Join(", ", Verificationpairs);
                            return (false, $"Verification CheckList is incomplete. Questions under sections {groupedString}. Must include a comment for responses marked No or N/A.");
                        }

                        // check for planner checklist is complete
                        var Plannercategories = DataParser.GetListFromData<string>(result.Data2, "QuestionCategory");
                        var Plannerquestions = DataParser.GetListFromData<string>(result.Data2, "QuestionOrder");

                        // pair category + order together
                        var Plannerpairs = Plannercategories.Zip(Plannerquestions, (cat, ord) => new { Category = cat, Order = ord })
                                              .Where(x => !string.IsNullOrWhiteSpace(x.Category) && !string.IsNullOrWhiteSpace(x.Order))
                                              .GroupBy(x => x.Category)
                                              .Select(g => $"( {g.Key} : {string.Join(", ", g.Select(x => x.Order))} )");

                        if (Plannerpairs.Any())
                        {
                            var groupedString = string.Join(", ", Plannerpairs);
                            return (false, $"Planner CheckList is incomplete. Questions under sections {groupedString}. Must include a comment for responses marked No or N/A.");
                        }

                        break;

                    }
                case "ASMA":
                    {
                        break;
                    }
                default:
                    return (true, "");
            }

            if (result.Data1.Count > 0)
            {
                string? message = DataParser.GetValueFromData<string>(result.Data1, "ErrorMessage");
                if (!string.IsNullOrEmpty(message))
                {
                    return (false, message);
                }
            }

            return (true, "");
        }
        catch (Exception e)
        {
            return (false, e.Message);
        }
    }

    public async Task<PCCResult> GetPCCMain(PCCGetPCCMainRequest request)
    {
        var model = new PCCProcedure
        {
            RecordType = request.Type,
            EmployeeID = request.EmployeeID
        };
        var result = await _repository.Op_01(model);

        var pccOptions = new JsonSerializerOptions
        {
            Converters = { new PCCMainConverter() }
        };
        var pccDict = JsonSerializer.Serialize(result.Data1);
        var pccMain = JsonSerializer.Deserialize<List<PCCMain>>(pccDict, pccOptions);

        var pccResult = new PCCResult();

        var employeeIDs = new List<string> { request.EmployeeID };
        var delegationIDs = new List<string>(DataParser.GetListFromData(result.Data2, "EmployeeID"));

        var finalRecords = new List<PCCMain>();

        foreach (var record in pccMain)
        {
            if (PCCStaticFunctions.IsMyRecord(record, employeeIDs))
            {
                record.DropdownFilter = "MyWork";
            }

            else if (PCCStaticFunctions.IsMyRecord(record, delegationIDs))
            {
                record.DropdownFilter = "MyDelegation";
            }
            finalRecords.Add(record);
        }
        pccResult.Data1 = finalRecords?.Cast<object>().ToList();
        return pccResult;
    }

    public async Task<(bool, List<string>)> ValidatePBRFHeader(int uniqueID)
    {
        var result = await _repository.Op_08(new PCCProcedure { Num1 = uniqueID, SubOp = 2 });

        var pbrf = DataParser.GetModelFromObject<PBRFModel>(result.Data1[0]);

        if (pbrf != null)
        {
            return Validation.ValidationPBRF.IsHeaderValid(pbrf);
        }
        return (true, new List<string> { "Internal server error; PBRF model not created" });
    }

    private async Task<(bool, List<string>)> ValidateChecklist(List<object> data)
    {
        var response = DataParser.GetModelFromObject<List<SDQChecklistResponse>>(data);

        if (response != null)
            foreach (var checklist in response)
            {
                if (!checklist.IsValid)
                    return (false, new List<string> { checklist.ChecklistItemID });
            }
        return (true, new List<string>());
    }

    public async Task<Dictionary<string, object>> GetSDQPDFReport(int SDQUID)
    {
        var model = new PCCProcedure { SDQID = SDQUID };
        var longModel = new PCCProcedure
        {
            RecordUID = SDQUID,
            RecordType = "SDQ"
        };

        var tasks = new List<Func<Task<PCCResult>>>
    {
        () => _repository.Op_08(new PCCProcedure { Num1 = SDQUID, SubOp = 1 }),        // 0 - sdq main
        () => _repository.Op_10(new PCCProcedure { Num1 = SDQUID }),                   // 1 - sdq unit
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 6 }),       // 2 - projects
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 7 }),       // 3 - deliverables
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 8 }),       // 4 - cii deliverables
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 9 }),       // 5 - cii org
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 10 }),      // 6 - cii sds
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 11 }),      // 7 - cii phase
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 24 }),      // 8 - cii phase summary
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 12 }),      // 9 - cv wbs
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 13 }),      // 10 - cv phase
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 14 }),      // 11 - cv sds
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 15 }),      // 12 - cv phase view
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 16 }),      // 13 - cv phase summary
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 17 }),      // 14 - sds-summary-cii
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 18 }),      // 15 - sds-summary-cv
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 20 }),      // 17 - forecast
        // _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 19 }),      // 16 - sds-summary-lamp
        
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 21 }),      // 18 - forecast-cii
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 22 }),      // 19 - forecast-cpv
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 23 }),      // 20 - discipline
                    //_repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 27 }),      // 21 - pmpc
        () => _repository.Op_11(new PCCProcedure { SDQID = SDQUID, SubOp = 29 }),      // 22 - financial-summary
        () => _repository.Op_21(new PCCProcedure { SDQID = SDQUID, SubOp = 1 }),       // 23 - customer approval
        
        () => _repository.Op_56(model),                                               // 24 - eac variance
        () => _repository.Op_57(model),                                               // 25 - eac revised commitments
        () => _repository.Op_59(model),                                               // 26 - eac trend
        () => _repository.Op_60(model),                                               // 27 - eac engineering

        () => _repository.Op_66(model),                                               // 28 - pdf signatures
        () => _repository.Op_67(model),                                               // 29 - previous eac
        () => _repository.Op_76(longModel),                                               // 30 - long fields
    };

        var keys = new[]
        {
        "sdq-main", "sdq-unit", "projects", "deliverables", "cii-deliverables", "cii-org", "cii-sds", "cii-phase",
        "cii-phase-summary", "cv-wbs", "cv-phase", "cv-sds", "cv-phase-view", "cv-phase-summary", "sds-summary-cii",
        "sds-summary-cv", "forecast", "forecast-cii", "forecast-cpv", "discipline",
        "financial-summary", "customer-approval", "eac-variance", "eac-revised-commitments", "eac-trend",
        "eac-engineering", "pdf-signatures", "previous-eac", "sdq-long-fields"
    };

        var report = new Dictionary<string, object>();
        var semaphore = new SemaphoreSlim(2); // limit concurrency
        var results = new PCCResult[tasks.Count];

        // sanity check
        if (keys.Length != tasks.Count)
            throw new InvalidOperationException($"keys length ({keys.Length}) != tasks count ({tasks.Count})");

        var taskList = tasks.Select((func, index) => Task.Run(async () =>
        {
            await semaphore.WaitAsync();
            try
            {
                var sw = Stopwatch.StartNew();
                try
                {
                    results[index] = await func() ?? new PCCResult { Data1 = new List<object>() };
                    sw.Stop();
                    Console.WriteLine($"Operation {keys[index]} took {sw.Elapsed.TotalSeconds:F2}s");
                }
                catch (Exception ex)
                {
                    sw.Stop();
                    Console.WriteLine($"ERROR: {keys[index]} failed after {sw.Elapsed.TotalSeconds:F2}s: {ex.Message}");
                    Console.WriteLine(ex);
                    results[index] = new PCCResult { Data1 = new List<object>() }; // safe placeholder
                    // do not rethrow — continue with other tasks
                }
            }
            finally
            {
                semaphore.Release();
            }
        })).ToList();

        await Task.WhenAll(taskList);

        for (int i = 0; i < results.Length; i++)
        {
            var prop = results[i].GetType().GetProperty(i == 1 ? "Data2" : "Data1");
            if (prop != null)
            {
                report[keys[i]] = prop.GetValue(results[i])!;
            }
            else
            {
                report[keys[i]] = null!;
            }
        }

        return report;
    }

    public async Task<PCCResult> GetDropdownOptions(int operation)
    {
        return await _repository.Op_90(new PCCProcedure { SubOp = Convert.ToByte(operation) });
    }

    public async Task<PCCResult> P6Run(PCCProcedure model)
    {
        return await _repository.Op_11(model);
    }
}