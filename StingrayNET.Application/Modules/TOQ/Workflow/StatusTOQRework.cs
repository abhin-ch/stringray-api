using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.Models;

namespace StingrayNET.Application.Modules.TOQ.Workflow;

public class StatusTOQRework : BaseStatus<TOQModel>
{
    public StatusTOQRework(TOQModel model) : base(model) { }

    public StatusTOQRework(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(TOQModel model)
    {
        var user = model.User;
        var hasBrucePowerRole = user.BPRoles?.Any(x => !string.IsNullOrEmpty(x));
        var _repository = model.Repository;

        switch (model.StatusCode)
        {
            case DEDStatusEnum.INIT:
                {
                    if (user.HasRole("OE") || user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ASMA, "Send to SM for Approval");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.ASMA:
                {
                    if (user.HasRole("SM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AVNR, "Send to vendor for response");
                        AddOption(DEDStatusEnum.INIT, "Send back to OEL");
                    }
                    break;
                }
            case DEDStatusEnum.AVNR:
                {
                    if (user.IsVendor || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.VACC, "Vendor Accept");
                        AddOption(DEDStatusEnum.VDEC, "Vendor Decline");
                    }
                    break;
                }
            case DEDStatusEnum.VACC:
                {
                    // No further status changes available for VACC
                    break;
                }
            case DEDStatusEnum.VDEC:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.INIT, "Move back to the OE (Initiated Status)");
                    }
                    break;
                }
            default:
                break;
        }
    }

    protected override BaseStatus<TOQModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusTOQRework(statusCode, label);
    }
}