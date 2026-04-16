
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.PCC;

namespace StingrayNET.Application.Modules.PCC.Workflow;

public class StatusPBRF : BaseStatus<PCCModel>
{
    const int maximumCost = 500000;

    public StatusPBRF(PCCModel model) : base(model)
    {
    }

    public StatusPBRF(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(PCCModel model)
    {
        var procedure = new PCCProcedure { RecordType = "PBRF", Value1 = model.StatusCodeString, PBRID = model.ID, EmployeeID = model.EmployeeID };

        //var user = GetUserRole();
        switch (model.StatusCode)
        {
            case DEDStatusEnum.AEBSP:
                {
                    if (model.User.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APPC, "Approve & Complete");
                        AddOption(DEDStatusEnum.ADIVM, "Send to DivM for Approval");
                        AddOption(DEDStatusEnum.CORR, "Send to Initiator for Correction");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }

                    break;
                }
            case DEDStatusEnum.AAEBS:
                {
                    // var result = _repository!.Op_15(new PCCProcedure { Value1 = nameof(DEDStatusEnum.AAEBS) }).Result;
                    // var totalCost = DataParser.GetValueFromData<int>(result.Data1, "TotalCost");

                    // Must be under 500K

                    if (model.User.HasRole("EBS") || model.IsAdmin)
                    {
                        // Only EBS Role can cancel at this status
                        AddOption(DEDStatusEnum.APPC, "Approve & Complete");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.ADIVM:
                {
                    AddOption(DEDStatusEnum.AAEBS, "Approve and Send to EBS for Processing");
                    AddOption(DEDStatusEnum.CORR, "Send to Initiator for Correction");
                    AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                    break;
                }
            case DEDStatusEnum.ADMA:
                {
                    var result = model.Repository.Op_19(procedure).Result;
                    var state = DataParser.GetValueFromData<string>(result.Data1, "Status");

                    if (model.User.HasRole("DM") || model.IsAdmin || state == "DivM")
                    {
                        AddOption(DEDStatusEnum.AEBSP, "Approve and Send to EBS for Processing");
                        AddOption(DEDStatusEnum.CORR, "Send to Initiator for Correction");
                    }
                    break;

                }

            case DEDStatusEnum.APPC:
                {
                    // DUPLICATE PBRF with a new UniqueID
                    break;
                }
            case DEDStatusEnum.ASMA:
                {
                    var result = model.Repository.Op_19(procedure).Result;
                    var state = DataParser.GetValueFromData<string>(result.Data1, "Status");

                    if (model.User.HasRole("SM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ADMA, "Approve and Send to DM for Approval");
                        AddOption(DEDStatusEnum.CORR, "Send to Initiator for Correction");
                    }
                    else if (state == "DM")
                    {
                        AddOption(DEDStatusEnum.AEBSP, "Approve and Send to EBS for Processing");

                        AddOption(DEDStatusEnum.CORR, "Send to Initiator for Correction");
                    }
                    break;
                }
            case DEDStatusEnum.NTAPP:
            case DEDStatusEnum.CANC:
            case DEDStatusEnum.SUPER:
                {
                    //disable button
                    break;
                }
            case DEDStatusEnum.CORR:
                {
                    AddOption(DEDStatusEnum.ASMA, "Send to SM for Approval");
                    AddOption(DEDStatusEnum.CANC, "Cancel");
                    break;
                }
            case DEDStatusEnum.INIT:
                {
                    AddOption(DEDStatusEnum.ASMA, "Send to SM for Approval");
                    AddOption(DEDStatusEnum.CANC, "Cancel");
                    break;
                }

            default:
                break;
        }
    }

    protected override BaseStatus<PCCModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusPBRF(statusCode, label);
    }
}