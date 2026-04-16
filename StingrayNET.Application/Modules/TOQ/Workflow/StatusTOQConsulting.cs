using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.HelperFunctions;

namespace StingrayNET.Application.Modules.TOQ.Workflow;

public class StatusTOQConsulting : BaseStatus<TOQModel>
{
    public StatusTOQConsulting(TOQModel model) : base(model) { }

    public StatusTOQConsulting(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(TOQModel model)
    {
        var user = model.User;
        var hasBrucePowerRole = user.BPRoles?.Any(x => !string.IsNullOrEmpty(x));
        var _repository = model.Repository;

        switch (model.StatusCode)
        {
            case DEDStatusEnum.INIT:
            case DEDStatusEnum.ICORR:
                {
                    if (hasBrucePowerRole == true || model.IsAdmin)
                    {
                        // First step after INIT/ICORR is this step, then follows standard TOQ flow
                        AddOption(DEDStatusEnum.ADMSA, "Send to DM EP for Scope Approval");
                    }
                    AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    AddOption(DEDStatusEnum.DEL, "Delete TOQ");
                    break;
                }
            case DEDStatusEnum.ADMSA:
                {
                    if (user.HasRole("DM EP") || model.IsAdmin)
                    {
                        var result = _repository!.Op_11(new Procedure { SubOp = 1, Num1 = Row.ID }).Result;
                        var hasMultipleVendors = DataParser.GetValueFromData<int>(result.Data1, "VendorCount");
                        if (hasMultipleVendors > 1)
                        {
                            //If initiator selects multiple vendors, the flow will require SM Approval.
                            AddOption(DEDStatusEnum.ASMIA, "Submit to SM for approval");
                        }
                        else
                        {
                            AddOption(DEDStatusEnum.AEIA, "Submit to EBS for approval");
                        }
                        AddOption(DEDStatusEnum.ICORR, "Send back to TDS initiation");
                    }
                    break;
                }
            default:
                var status = new StatusTOQStandard(model);
                AddOptions(status.Options);
                break;
        }
    }

    protected override BaseStatus<TOQModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusTOQConsulting(statusCode, label);
    }
}
