using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.PCC;

namespace StingrayNET.Application.Modules.PCC.Workflow;

public class StatusDVN : BaseStatus<PCCModel>
{
    const int maximumCost = 500000;

    public StatusDVN(PCCModel model) : base(model) { }

    public StatusDVN(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(PCCModel model)
    {
        //var user = GetUserRole();
        switch (model.StatusCode)
        {
            case DEDStatusEnum.ACAPP:
                {
                    AddOption(DEDStatusEnum.APPC, "Approve & Complete");
                    AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                    break;
                }
            case DEDStatusEnum.ADPA:
                {
                    AddOption(DEDStatusEnum.ACAPP, "Approve & Submit to Customer");
                    AddOption(DEDStatusEnum.APPC, "Approve & Complete");
                    break;
                }
            case DEDStatusEnum.AOEA:
                {
                    AddOption(DEDStatusEnum.AVER, "Send to PCS Lead for Verification");
                    AddOption(DEDStatusEnum.INIT, "Send back for DVN Correction Required");
                    break;
                }
            case DEDStatusEnum.NTAPP:
            case DEDStatusEnum.APPC:
                {
                    //disable button
                    break;
                }
            case DEDStatusEnum.ASMA:
                {
                    AddOption(DEDStatusEnum.ADPA, "Approve & Submit for DM EP Approval");
                    AddOption(DEDStatusEnum.INIT, "Send back for DVN Correction Required");
                    break;
                }
            case DEDStatusEnum.AVER:
                {
                    AddOption(DEDStatusEnum.ASMA, "Approve & Submit for discipline SM Approval");
                    AddOption(DEDStatusEnum.INIT, "Send back for DVN Correction Required");
                    break;
                }
            case DEDStatusEnum.INIT:
                {
                    AddOption(DEDStatusEnum.AOEA, "Passed Verification & Submit for OE Approval");
                    break;
                }
            default:
                break;

        }

    }
    protected override BaseStatus<PCCModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusDVN(statusCode, label);
    }
}