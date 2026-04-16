using System;
using System.Linq;
using StingrayNET.ApplicationCore.HelperFunctions;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.Models;

namespace StingrayNET.Application.Modules.TOQ.Workflow;

public class StatusTOQEmergent : BaseStatus<TOQModel>
{
    public StatusTOQEmergent(TOQModel model) : base(model) { }

    public StatusTOQEmergent(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(TOQModel model)
    {
        var user = model.User;
        var hasBrucePowerRole = user.BPRoles?.Any(x => !string.IsNullOrEmpty(x));

        switch (model.StatusCode)
        {
            case DEDStatusEnum.INIT:
                {
                    if (hasBrucePowerRole == true || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ADMA, "Send to DM EP for Approval");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.CORR:
                {
                    if (hasBrucePowerRole == true || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ADMA, "Send to DM EP for Approval");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.ADMA:
                {
                    if (user.HasRole("DM EP") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AVENA, "Send to Vendor for Acceptance");
                        AddOption(DEDStatusEnum.CORR, "Correction Required");
                        AddOption(DEDStatusEnum.RDDMEP, "Request Denied");
                    }
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.AVENA:
                {
                    if (user.IsVendor || model.IsAdmin || user.HasRole("Design Engineering"))
                    {
                        AddOption(DEDStatusEnum.ACC, "Accept Emergent Request");
                        AddOption(DEDStatusEnum.CORR, "Correction Required");
                        AddOption(DEDStatusEnum.RDV, "Request Denied");
                    }

                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }

            case DEDStatusEnum.ACC:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.RES, "Resolve");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.DEL:
            //Removes Record


            default:
                break;
        }
    }

    protected override BaseStatus<TOQModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusTOQEmergent(statusCode, label);
    }
}