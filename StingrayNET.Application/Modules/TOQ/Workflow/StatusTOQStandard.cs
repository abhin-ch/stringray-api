using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.Models;

namespace StingrayNET.Application.Modules.TOQ.Workflow;

public class StatusTOQStandard : BaseStatus<TOQModel>
{

    public StatusTOQStandard(TOQModel model) : base(model)
    {
    }

    public StatusTOQStandard(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

    protected override void NextStatus(TOQModel model)
    {
        var user = model.User;
        var hasBrucePowerRole = user?.BPRoles?.Any(x => !string.IsNullOrEmpty(x));
        var _repository = model.Repository;

        switch (model.StatusCode)
        {
            case DEDStatusEnum.INIT:
                {
                    if (hasBrucePowerRole == true || model.IsAdmin)
                    {
                        // Anyone can perform these actions
                        var result = _repository.Op_11(new Procedure { SubOp = 1, Num1 = model.ID }).Result;
                        var hasMultipleVendors = DataParser.GetValueFromData<int>(result.Data1, "VendorCount");

                        //competitive bid so go to SM 
                        if (hasMultipleVendors > 1)
                        {
                            //If initiator selects multiple vendors, the flow will require SM Approval.
                            AddOption(DEDStatusEnum.ASMIA, "Submit to SM for approval");
                        }
                        else
                        {
                            AddOption(DEDStatusEnum.AEIA, "Submit to EBS for approval");
                        }
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                        AddOption(DEDStatusEnum.DEL, "Delete TOQ");

                    }
                    break;
                }
            case DEDStatusEnum.ICORR:
                {
                    if (hasBrucePowerRole == true || model.IsAdmin)
                    {
                        var result = _repository!.Op_11(new Procedure { SubOp = 1, Num1 = model.ID }).Result;
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

                        // AddOption(DEDStatusEnum.EMGT, EMER);
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ"); //EBS Spoc will be the only one with this option.
                        break;
                    }
                    break;
                }
            case DEDStatusEnum.CORR:
                {
                    if (user.HasRole("OE"))
                    {
                        AddOption(DEDStatusEnum.ASAA, "Partially award vendor and send to SM for approval");
                        AddOption(DEDStatusEnum.AVSA, "Award vendor and send to SM for approval");
                        AddOption(DEDStatusEnum.ACANC, "Awaiting Cancellation Approval");
                    }
                    else if (user.HasRole("EBS"))
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    else if (model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ASAA, "Award Vendor & Submit to SM for Approval");
                        AddOption(DEDStatusEnum.ACANC, "Awaiting Cancellation Approval");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }
            case DEDStatusEnum.ACANC:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Approve Cancellation");
                        AddOption(DEDStatusEnum.AOEVA, "Reject Cancellation & move to Awaiting OEL Vendor Award");
                    }
                    break;
                }
            case DEDStatusEnum.ASMIA:
                {
                    if (user.HasRole("SM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AEIA, "Approve and submit to EBS");
                        AddOption(DEDStatusEnum.INIT, "Send back to Initiation");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                    }
                    break;
                }

            case DEDStatusEnum.AEIA:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AVS, "Submit to Vendor(s)");
                        AddOption(DEDStatusEnum.INIT, "Send back to Initiation");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }

            case DEDStatusEnum.AVS:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        // EBS-specific options
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }

            case DEDStatusEnum.AEBSP:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AOEVA, "Send to OEL for Vendor Selection");
                        AddOption(DEDStatusEnum.INIT, "Send back to Initiation");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }

            case DEDStatusEnum.AOEVA:
                {
                    if (user.HasRole("OE") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ASAA, "Partially award vendor and send to SM for approval");
                        AddOption(DEDStatusEnum.AVSA, "Award vendor and send to SM for approval");
                        AddOption(DEDStatusEnum.ACANC, "Request to Cancel TOQ");
                        AddOption(DEDStatusEnum.ALAMS, "Awaiting LAMP Submission");
                        AddOption(DEDStatusEnum.HSDQ, "Hold for SDQ");

                        // Conditional transitions based on funding
                        var requiresFunding = false; // Implement this method   
                        if (!requiresFunding)
                        {
                            //AddOption(DEDStatusEnum.ACOR, "No funding required");
                        }
                        // Otherwise, the status will go to HOLDSF or other appropriate status
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                    }
                    break;
                }

            case DEDStatusEnum.ALAMS:
                {
                    if (user.HasRole("OE") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ASAA, "Award vendor and send to SM for approval");
                        AddOption(DEDStatusEnum.ACANC, "Request to Cancel TOQ");
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                    }
                    break;
                }
            case DEDStatusEnum.AVSA:
            case DEDStatusEnum.ASAA:
                {
                    if (user.HasRole("SM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ACOR, "Approve & send to EBS for Commercial Review");
                        AddOption(DEDStatusEnum.CORR, "Send to OEL for correction");
                    }
                    if ((user.HasRole("EBS") && user.HasRole("SM")) || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    if (user.HasRole("EBS") || user.IsTOQAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                    }
                    break;
                }

            case DEDStatusEnum.HSDQ:
                {
                    // Automatic transition logic needs to be handled
                    // TO DO: Automatic check if an SDQ has been linked or N/A with justification added, then move the status back to Await OE Vendor Award
                    AddOption(DEDStatusEnum.AOEVA, "Return to Awaiting OEL Vendor Award ");
                    break;
                }


            case DEDStatusEnum.ACOR:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AESAA, "Funding approved and send to EBS SM for approval");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }

            case DEDStatusEnum.AESAA:
                {
                    if ((user.HasRole("EBS") && user.HasRole("SM")) || model.IsAdmin)
                    {
                        const decimal MAX_RELEASE = 100000;
                        var result = _repository!.Op_11(new Procedure { SubOp = 4, Num1 = model.ID }).Result;
                        var awardedTotalCost = DataParser.GetValueFromData<decimal>(result.Data1, "TotalCost");

                        if (awardedTotalCost > MAX_RELEASE)
                        {
                            AddOption(DEDStatusEnum.ACCF, "Approve and award (Under 100K or other reason)");
                        }
                        else
                        {
                            AddOption(DEDStatusEnum.ACC, "Approve and award (Under 100K or other reason)");
                        }

                        AddOption(DEDStatusEnum.ADMA, "Send to DM EP for Approval");
                        AddOption(DEDStatusEnum.ADVMA, "Send to DM EP & DivM for Approval");
                        AddOption(DEDStatusEnum.ACOR, "Send Back for Commercial Review");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.NTAPP, "Not Approved");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }

            case DEDStatusEnum.ADMA:
                {
                    if (user.HasRole("DM EP") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AEFP, "Approve & send to EBS for processing");
                        AddOption(DEDStatusEnum.ACOR, "Send back for Commercial Review");
                    }
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }
            case DEDStatusEnum.ADVMA:
                {
                    if (user.HasRole("DM EP") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ADIVA, "Approve & send to DivM for approval");
                        AddOption(DEDStatusEnum.ACOR, "Send back for Commercial Review");
                    }
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }
            case DEDStatusEnum.ADIVA:
                {
                    if (user.HasRole("DivM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AEFP, "Approve & send to EBS for processing");
                        AddOption(DEDStatusEnum.ACOR, "Send Back for Commercial Review");
                    }

                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }

                    break;
                }

            case DEDStatusEnum.AVPA:
                {
                    if (user.HasRole("VP") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Approve & award");
                        AddOption(DEDStatusEnum.ACOR, "Send Back for Commercial Review");
                    }

                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }

                    break;
                }

            case DEDStatusEnum.AEFP:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Approve and award");
                        AddOption(DEDStatusEnum.AVPA, "Send to Awaiting VP Approval");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }

            case DEDStatusEnum.ASVPA:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Approve and award");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel TOQ");
                    }
                    break;
                }
            case DEDStatusEnum.ACCF:
            case DEDStatusEnum.ACC:
                {
                    var resultPartial = _repository!.Op_11(new Procedure { SubOp = 2, Num1 = model.ID }).Result;
                    var isPartial = DataParser.GetValueFromData<bool>(resultPartial.Data1, "IsPartial");
                    //TODP: Multiple roles can perform these actions
                    if (user.HasRole("OE") || user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CLOSE, "Close TOQ");
                        if (isPartial)
                        {
                            AddOption(DEDStatusEnum.ADPR, "Additional Partial Release");
                        }
                    }

                    if (user.HasRole("OE") || user.HasRole("EBS") || user.HasRole("SM") || model.IsAdmin)
                    {
                        var result = _repository!.Op_11(new Procedure { SubOp = 3, Num1 = model.ID }).Result;
                        var canRevision = DataParser.GetValueFromData<bool>(result.Data1, "CanRevision");
                        if (canRevision)
                            AddOption(DEDStatusEnum.ARIP, "New Revision");
                    }
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        if (isPartial)
                        {
                            AddOption(DEDStatusEnum.FULLR, "TOQ Fully Released");
                        }
                    }
                    break;
                }

            case DEDStatusEnum.APPR:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APR, "Release Additional Funding");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                    }
                    break;
                }

            case DEDStatusEnum.ADPR:
                {
                    if (user.HasRole("OE") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APCOR, "Send to EBS for Partial Review");
                    }
                    break;
                }

            case DEDStatusEnum.APR:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APCOR, "Send to OEL for Further Financial Information");
                        AddOption(DEDStatusEnum.ICORR, "Send to Initial Correction Required");
                    }
                    break;
                }

            case DEDStatusEnum.APCOR:
                {

                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Approve and award");
                        AddOption(DEDStatusEnum.ADPR, "Send back for Additional Partial Release");
                    }
                    break;
                }
            // Late Start Workflow
            case DEDStatusEnum.VDU:
                {
                    if (user.IsVendor || model.IsAdmin)
                    {
                        // Commented this out as it's controlled by 'Submit TOQ' button for the vendor
                        // AddOption(DEDStatusEnum.ODU, "Approve Date Update and Send to OEL");
                    }
                    break;
                }
            case DEDStatusEnum.ODU:
                {
                    if (user.HasRole("OE") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ACC, "Approve Date Update");
                        AddOption(DEDStatusEnum.VDU, "Send Date Update Back to Vendor");
                    }
                    break;
                }
            case DEDStatusEnum.ARIP:
                {

                    if (user.HasRole("OE") || user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CLOSE, "Close TOQ");


                        var result = _repository!.Op_11(new Procedure { SubOp = 2, Num1 = model.ID }).Result;
                        var isPartial = DataParser.GetValueFromData<bool>(result.Data1, "IsPartial");
                        if (isPartial)
                        {
                            AddOption(DEDStatusEnum.ADPR, "Additional Partial Release");
                            if (user.HasRole("EBS") || model.IsAdmin)
                            {
                                AddOption(DEDStatusEnum.FULLR, "TOQ Fully Released");
                            }
                        }
                    }

                    break;
                }
            case DEDStatusEnum.CANC:
                {
                    if (user.HasRole("EBS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.DEL, "Delete TOQ");
                    }
                    break;
                }
            // No change status options for the following statuses
            case DEDStatusEnum.REP:
            case DEDStatusEnum.SUPER:
            case DEDStatusEnum.NTAPP:
            case DEDStatusEnum.CLOSE:
                {
                    // No options to add
                    break;
                }
            default:
                throw new ArgumentException($"Standard TOQ Type: StatusCode ({Enum.GetName(typeof(DEDStatusEnum), model.StatusCode)}) not found");
        }
    }

    protected override BaseStatus<TOQModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusTOQStandard(statusCode, label);
    }
}