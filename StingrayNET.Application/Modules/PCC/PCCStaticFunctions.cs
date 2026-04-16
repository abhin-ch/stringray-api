
using StingrayNET.ApplicationCore.Models.PCC;

namespace StingrayNET.Application.Modules.PCC;

public static class PCCStaticFunctions
{
    public static bool IsMyRecord(PCCMain record, List<string> employeeIDs)
    {
        var status = record.StatusValue;

        bool HasAny(params string[] values) => values.Any(v => employeeIDs.Contains(v));

        return
            (employeeIDs.Contains(record.RequestFromID) && PBRFStatuses.Contains(status)) ||
            (employeeIDs.Contains(record.SMID) && status == "ASMA") ||
            (employeeIDs.Contains(record.DMID) && status == "ADMA") ||
            (employeeIDs.Contains(record.DivMID) && status == "ADIVM") ||
            (record.IsEBS.Value && PBRFEBSStatuses.Contains(status)) ||
            (employeeIDs.Contains(record.PCSID) && SDQStatuses.Contains(status)) ||
            (!string.IsNullOrEmpty(record.PendingApprovers) &&
                SDQPendingStatuses.Contains(status) &&
                employeeIDs.Any(id => record.PendingApprovers.Contains(id))) ||

            (employeeIDs.Contains(record.OEID) && SDQOEStatuses.Contains(status)) ||
            (employeeIDs.Contains(record.ProgMID) && status == "APGMA") ||
            (employeeIDs.Contains(record.ProjMID) && status == "APJMA") ||
            (employeeIDs.Contains(record.DMEPID) && status == "ADPA") ||
            (record.IsLeadPlanner.Value && status == "AVER") ||
            (employeeIDs.Contains(record.PCSID) && DVNPCSStatuses.Contains(status)) ||
            (employeeIDs.Contains(record.VerifierID) && status == "AVER") ||
            (employeeIDs.Contains(record.OEID) && status == "AOEA") ||
            (employeeIDs.Contains(record.DMEPID) && status == "ADMA") ||
            (employeeIDs.Contains(record.ProjMID) && status == "APMA");
    }
    private static readonly HashSet<string> SDQStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "INIT", "CORR", "APCSC", "APRE", "PCSCR", "PCSCRPROG", "CANC"
    };

    private static readonly HashSet<string> SDQPendingStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "ASMA", "AVER"
    };

    private static readonly HashSet<string> SDQOEStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "AOEA", "AOEFR", "AOERC"
    };

    private static readonly HashSet<string> PBRFStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "INIT", "CORR"
    };

    private static readonly HashSet<string> PBRFEBSStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "AEBSP", "AAEBS"
    };

    private static readonly HashSet<string> DVNPCSStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "I", "CR", "PCSCR"
    };
}