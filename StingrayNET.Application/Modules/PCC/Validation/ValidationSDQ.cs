using StingrayNET.ApplicationCore.Models.PCC.SDQ;

namespace StingrayNET.Application.Modules.PCC.Validation;

public class ValidationSDQ
{
    public bool IsValid(SDQModel sdq, out List<string> missingFields)
    {
        missingFields = new List<string>();

        if (string.IsNullOrEmpty(sdq.DEDPlanner))
            missingFields.Add(nameof(SDQModel.DEDPlanner));
        if (string.IsNullOrEmpty(sdq.PCS))
            missingFields.Add(nameof(SDQModel.PCS));
        if (string.IsNullOrEmpty(sdq.OE))
            missingFields.Add(nameof(SDQModel.OE));
        if (string.IsNullOrEmpty(sdq.SM))
            missingFields.Add(nameof(SDQModel.SM));
        if (string.IsNullOrEmpty(sdq.DM))
            missingFields.Add(nameof(SDQModel.DM));
        if (string.IsNullOrEmpty(sdq.ProjectM))
            missingFields.Add(nameof(SDQModel.ProjectM));
        if (string.IsNullOrEmpty(sdq.ProgramM))
            missingFields.Add(nameof(SDQModel.ProgramM));
        if (sdq.PreviouslyApproved == null)
            missingFields.Add(nameof(SDQModel.PreviouslyApproved));
        if (sdq.RequestedScope == null)
            missingFields.Add(nameof(SDQModel.RequestedScope));
        if (string.IsNullOrEmpty(sdq.FundingSource))
            missingFields.Add(nameof(SDQModel.FundingSource));
        if (string.IsNullOrEmpty(sdq.Verifier))
            missingFields.Add(nameof(SDQModel.Verifier));
        if (string.IsNullOrEmpty(sdq.Complexity))
            missingFields.Add(nameof(SDQModel.Complexity));
        if (string.IsNullOrEmpty(sdq.BusinessDriver))
            missingFields.Add(nameof(SDQModel.BusinessDriver));
        if (string.IsNullOrEmpty(sdq.PrimaryDiscipline))
            missingFields.Add(nameof(SDQModel.PrimaryDiscipline));
        if (sdq.DMApprovalDate == null)
            missingFields.Add(nameof(SDQModel.DMApprovalDate));

        return missingFields.Count == 0;
    }

    public (bool, List<string>) IsSelfChecklistValid(SDQModel sdq)
    {
        return (false, new List<string> { "" });
    }
}