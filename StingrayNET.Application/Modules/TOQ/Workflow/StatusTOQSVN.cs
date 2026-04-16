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

public class StatusTOQSVN : BaseStatus<TOQModel>
{
    public StatusTOQSVN(TOQModel model) : base(model) { }

    public StatusTOQSVN(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(TOQModel model)
    {
        var user = model.User;
        var hasBrucePowerRole = user.BPRoles?.Any(x => !string.IsNullOrEmpty(x));
        var _repository = model.Repository;

        switch (model.StatusCode)
        {
            case DEDStatusEnum.INIT:
                {
                    if (user.IsVendor || user.HasRole("EBS")) // Need to change this to Vendor PM
                    {
                        AddOption(DEDStatusEnum.AOEA, "Send to BP for processing");
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.ICORR:
                {
                    AddOption(DEDStatusEnum.AOEA, "Send to BP for processing");
                    AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    break;
                }
            case DEDStatusEnum.AOEA:
                {
                    if (user.HasRole("OE") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.ADMA, "Approve and send for processing"); //User will only see "Approve and send for processing" -> SVN type 1 - TOQ End Date only (5),SVN type 2- Both End date /deliverables (4)
                        AddOption(DEDStatusEnum.ICORR, "Send back to vendor for correction required");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved"); //No more change status option, vendor gets notification
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.ADMA:
                {
                    if (user.HasRole("DM EP") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.SVND, "Approve");
                        AddOption(DEDStatusEnum.ICORR, "Send back to vendor for correction required"); // OE MUST be included in Notification 
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved"); //No more change status option, vendor gets notification
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.SVNEBA:
                {
                    if ((user.HasRole("EBS") && user.HasRole("SM")) || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Approve");
                        AddOption(DEDStatusEnum.ICORR, "Send back to vendor for correction required");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.ACC:
            case DEDStatusEnum.CANC:
                {
                    //No change status option. 
                    break;
                }
            case DEDStatusEnum.NTAPP:
                {
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.SVNVI:
                {
                    if (user.IsVendor || user.IsTOQAdmin) // Need to change this to Vendor PM
                    {
                        AddOption(DEDStatusEnum.SVND, "Submit to EBS for dispositioning");
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.SVNOI:
                {
                    if (user.HasRole("OE") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.SVND, "Submit to EBS for dispositioning");
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.SVND:
                {
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Accept");
                        AddOption(DEDStatusEnum.SVNVI, "Send back to vendor to submit CR/Justification"); //Pending
                        AddOption(DEDStatusEnum.SVNOI, "Send back to OEL to submit CR/Justification"); //Pending
                        AddOption(DEDStatusEnum.CANC, "Cancel SVN");
                    }
                    break;
                }
            case DEDStatusEnum.DEL:
                {
                    //Removes record from FE.
                    break;
                }

            default:
                break;
        }
    }


    protected override BaseStatus<TOQModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusTOQSVN(statusCode, label);
    }
}