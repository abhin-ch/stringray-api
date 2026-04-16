using StingrayNET.ApplicationCore.Models.PCC.PBRF;

namespace StingrayNET.Application.Modules.PCC.Validation;

public class ValidationPBRF
{
    public static (bool, List<string>) IsHeaderValid(PBRFModel pbrf)
    {
        var missingFields = new List<string>();

        if (string.IsNullOrEmpty(pbrf.ProjectTitle))
            missingFields.Add(nameof(pbrf.ProjectTitle));
        if (string.IsNullOrEmpty(pbrf.Station))
            missingFields.Add(nameof(pbrf.Station));

        return (missingFields.Count == 0, missingFields);
    }
}