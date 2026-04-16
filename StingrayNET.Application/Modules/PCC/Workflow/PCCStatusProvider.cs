using Microsoft.Graph.Drives.Item.Items.Item.Workbook.Functions.Var_S;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.Requests.PCC;

namespace StingrayNET.Application.Modules.PCC.Workflow;

public interface IPCCStatusProvider
{
    Task<List<BaseStatus<PCCModel>>>? GetPCCStatusOptions(PCCModel model);
    Task<PCCModel> CreateModel(PCCStatusOptionsRequest request);
}

public class PCCStatusProvider : IPCCStatusProvider
{
    IRepositoryXL<PCCProcedure, PCCResult> _repository;

    public PCCStatusProvider(IRepositoryXL<PCCProcedure, PCCResult> repository)
    {
        _repository = repository;
    }

    public async Task<List<BaseStatus<PCCModel>>>? GetPCCStatusOptions(PCCModel model)
    {
        BaseStatus<PCCModel> status;
        switch (model.Type)
        {
            case "PBRF":
                {
                    status = new StatusPBRF(model);
                    await Task.CompletedTask;
                    return status.Options;
                }
            case "SDQ":
                {
                    status = new StatusSDQ(model);
                    await Task.CompletedTask;
                    return status.Options;
                }
            case "DVN":
                {
                    status = new StatusDVN(model);
                    await Task.CompletedTask;
                    return status.Options;
                }
            default:
                {
                    throw new Exception("GetPCCStatusOptions:PCC Type not found");
                }
        }
    }

    public Task<PCCModel> CreateModel(PCCStatusOptionsRequest request)
    {
        PCCModel body = null!;
        var status = Enum.Parse<DEDStatusEnum>(request.StatusValue, true);

        if (Enum.TryParse<PCCRecordTypeEnum>(request.RecordType, true, out var PCCRecordTypeEnum))
            switch (PCCRecordTypeEnum)
            {
                case PCCRecordTypeEnum.PBRF:
                    {
                        body = new PCCModel(PCCRecordTypeEnum.PBRF, request.EmployeeID, _repository, status)
                        {
                            ID = request.RecordUID,
                        };
                        break;
                    }
                case PCCRecordTypeEnum.SDQ:
                    {
                        body = new PCCModel(PCCRecordTypeEnum.SDQ, request.EmployeeID, _repository, status)
                        {
                            ID = request.RecordUID,
                            // SM = model.Value3, // ActiveEmployeeID
                            // ProgramM = model.Value3,
                            // ProjectM = model.Value3,
                            // DM = model.Value3,
                            // PCS = model.Value3,
                            // OE = model.Value3,
                            // Role = model.Value4
                        };
                        break;
                    }
                case PCCRecordTypeEnum.DVN:
                    {
                        body = new PCCModel(PCCRecordTypeEnum.DVN, request.EmployeeID, _repository, status)
                        {
                            ID = request.RecordUID,
                        };
                        break;
                    }
                default:
                    throw new System.Exception($"Record type of ({request.RecordType}) not found. Must be 'PBRF', 'SDQ', or 'DVN'.");
            }
        return Task.FromResult(body);
    }
}
