using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.PCC;

#nullable enable

namespace StingrayNET.Application.Modules.PCC.Workflow;

public class StatusSDQ : BaseStatus<PCCModel>
{
    public StatusSDQ(PCCModel model) : base(model) { }
    public StatusSDQ(DEDStatusEnum statusCode, string name) : base(statusCode, name)
    {
    }

    protected override BaseStatus<PCCModel> CreateStatus(DEDStatusEnum statusCode, string label)
    {
        return new StatusSDQ(statusCode, label);
    }

    protected override void NextStatus(PCCModel model)
    {
        var procedure = new PCCProcedure { RecordType = "SDQ", Value1 = model.StatusCodeString, SDQID = model.ID, EmployeeID = model.EmployeeID };

        switch (model.StatusCode)
        {
            case DEDStatusEnum.APJMA:
                {

                    if (model.User.HasRole("ProjectM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APGMA, "Approve & Send to Prog.M for Approval");
                        AddOption(DEDStatusEnum.PCSCR, "PCS/OE Clarification Required");
                    }
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.PCSCR:
                {
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APJMA, "Send to Proj.M for Approval");
                        AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.APGMA:
                {

                    if (model.User.HasRole("ProgramM") || model.IsAdmin)
                    {
                        var result = model.Repository.Op_19(procedure).Result;

                        var state = DataParser.GetValueFromData<string>(result.Data1, "Status");
                        switch (state)
                        {
                            case "AOERC":
                                AddOption(DEDStatusEnum.AOERC, "Approve & Send to DED");
                                break;
                            case "AOEFR":
                                AddOption(DEDStatusEnum.AOEFR, "Approve & Send to DED");
                                break;
                            case "APCSC":
                                AddOption(DEDStatusEnum.APCSC, "Approve & Send to DED");
                                break;
                            case "AFRE":
                                AddOption(DEDStatusEnum.AFRE, "Approve & Send to DED");
                                break;
                        }

                        AddOption(DEDStatusEnum.PCSCRPROG, "PCS/OE Clarification Required");
                    }
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel");

                    }
                    break;
                }
            case DEDStatusEnum.PCSCRPROG:
                {
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APGMA, "Send to Prog.M for Approval");
                        AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }

                    break;
                }
            case DEDStatusEnum.AOERC:
                {
                    if (model.User.HasRole("OE") || model.IsAdmin)
                    {
                        var result = model.Repository.Op_19(procedure).Result;

                        var state = DataParser.GetValueFromData<string>(result.Data1, "Status");
                        switch (state)
                        {
                            case "AOEFR":
                                AddOption(DEDStatusEnum.AOEFR, "Approve & Send to DED for Funding Release");
                                break;
                            case "APCSC":
                                AddOption(DEDStatusEnum.APCSC, "Send to PCS for Minor Change Resolution");
                                break;
                            case "AFRE":
                                AddOption(DEDStatusEnum.AFRE, "Approve & Send to DED");
                                break;
                        }
                    }

                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AFRE, "PCS/OE Clarification Required");
                        AddOption(DEDStatusEnum.APRE, "Approve & Send to DED");
                    }
                    break;
                }
            case DEDStatusEnum.ADPA:
                {
                    if (model.User.HasRole("DM EP") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.APJMA, "Approve & Submit to Customer for Approval");
                    }

                    AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");

                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.AFRE:
                {
                    //disabled when SDQ is on this status
                    break;
                }
            case DEDStatusEnum.AOEA:
                {
                    if (model.User.HasRole("OE") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AVER, "Send for Verification");
                    }
                    AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel");

                    }

                    break;
                }
            case DEDStatusEnum.AOEFR:
                {
                    if (model.User.HasRole("OE") || model.IsAdmin)
                    {
                        var result = model.Repository.Op_19(procedure).Result;

                        var state = DataParser.GetValueFromData<string>(result.Data1, "Status");
                        switch (state)
                        {
                            case "APCSC":
                                AddOption(DEDStatusEnum.APCSC, "Send to PCS for Minor Change Resolution");
                                break;
                            case "APRE":
                                AddOption(DEDStatusEnum.APRE, "Release Partial Funding with Comments");
                                break;
                        }
                    }
                    break;
                }
            case DEDStatusEnum.APRE:
                {
                    AddOption(DEDStatusEnum.APJMA, "Send back to customer for additional funding release");
                    break;
                }
            case DEDStatusEnum.ASMA:
                {
                    if (model.User.HasRole("SM") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ADPA, "Send to DMEP for approval");
                    }

                    AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");

                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }

                    break;
                }
            case DEDStatusEnum.AVER:
                {

                    if (model.User.HasRole("Lead Planner") || model.User.HasRole("PCS Lead") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.ASMA, "Send to SM(s) for approval");
                    }
                    AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");

                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }
                    break;
                }
            case DEDStatusEnum.CANC:
                {
                    //disable status button
                    break;
                }
            case DEDStatusEnum.CORR:
                {
                    AddOption(DEDStatusEnum.AOEA, "Send to OE for Approval");
                    AddOption(DEDStatusEnum.CANC, "Cancel");
                    break;
                }
            case DEDStatusEnum.INIT:
                {
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        AddOption(DEDStatusEnum.AOEA, "Send to OE for Approval");
                        AddOption(DEDStatusEnum.CANC, "Cancel");
                    }

                    break;
                }
            case DEDStatusEnum.APCSC:
                {
                    if (model.User.HasRole("PCS") || model.IsAdmin)
                    {
                        var result = model.Repository.Op_19(procedure).Result;

                        var state = DataParser.GetValueFromData<string>(result.Data1, "Status");
                        switch (state)
                        {
                            case "APRE":
                                AddOption(DEDStatusEnum.APRE, "Progress SDQ");
                                break;
                            case "AFRE":
                                AddOption(DEDStatusEnum.AFRE, "Progress SDQ");
                                break;
                        }
                        AddOption(DEDStatusEnum.CORR, "Send back to Initial Correction Required");
                        AddOption(DEDStatusEnum.CANC, "Cancel");

                    }

                    break;
                }
            case DEDStatusEnum.APPCSC:
                {
                    AddOption(DEDStatusEnum.APAMC, "Send to Admin for Final Review");
                    break;
                }
            case DEDStatusEnum.AAMC:
                {
                    AddOption(DEDStatusEnum.AFRE, "Progress SDQ");
                    break;
                }
            case DEDStatusEnum.APAMC:
                {
                    AddOption(DEDStatusEnum.APRE, "Progress SDQ");
                    break;
                }
            default:
                break;
        }
    }
}