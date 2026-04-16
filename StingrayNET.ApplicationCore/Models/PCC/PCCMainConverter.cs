using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.PCC;

public class PCCMainConverter : JsonConverter<PCCMain>
{
    public override PCCMain Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var dictionary = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(ref reader, options);
        var model = new PCCMain();

        string GetString(string key) => dictionary.TryGetValue(key, out var el) && el.ValueKind != JsonValueKind.Null ? el.GetString() : null;
        int? GetInt(string key)
        {
            if (!dictionary!.TryGetValue(key, out var el))
                return null;

            if (el.ValueKind == JsonValueKind.Number && el.TryGetInt32(out var numberVal))
                return numberVal;

            if (el.ValueKind == JsonValueKind.String && int.TryParse(el.GetString(), out var stringVal))
                return stringVal;

            return null;
        }
        decimal? GetDecimal(string key)
        {
            if (!dictionary!.TryGetValue(key, out var el))
                return null;

            if (el.ValueKind == JsonValueKind.Number && el.TryGetDecimal(out var numberVal))
                return numberVal;

            if (el.ValueKind == JsonValueKind.String && decimal.TryParse(el.GetString(), out var stringVal))
                return stringVal;

            return null;
        }
        DateTime? GetDateTime(string key) => dictionary!.TryGetValue(key, out var el) && el.TryGetDateTime(out var val) ? val : (DateTime?)null;
        bool? GetBool(string key) =>
            dictionary!.TryGetValue(key, out var el) && el.ValueKind == JsonValueKind.True ? true :
            dictionary.TryGetValue(key, out el) && el.ValueKind == JsonValueKind.False ? false :
            (bool?)null;

        model.Type = GetString("Type");
        model.UniqueID = GetString("UniqueID");
        model.RecordTypeUniqueID = GetInt("RecordTypeUniqueID");
        model.RecordID = GetString("RecordID");
        model.Revision = GetString("Revision");
        model.SubRevision = GetInt("SubRevision");
        model.LatestRevision = GetInt("LatestRevision");
        model.ParentPBRUID = GetString("ParentPBRUID");
        model.ProjectNo = GetString("ProjectNo");
        model.ProjectTitle = GetString("ProjectTitle");
        model.ProjectStatus = GetString("ProjectStatus");
        model.TargetDMApprovalDate = GetDateTime("TargetDMApprovalDate");
        model.TargetExecutionWindow = GetString("TargetExecutionWindow");
        model.StatusID = GetString("StatusID");
        model.Status = GetString("Status");
        model.StatusValue = GetString("StatusValue");
        model.CurrentStatusDate = GetDateTime("CurrentStatusDate");
        model.RequestDate = GetDateTime("RequestDate");
        model.RequestFrom = GetString("RequestFrom");
        model.RequestFromID = GetString("RequestFromID");
        model.PCS = GetString("PCS");
        model.PCSID = GetString("PCSID");
        model.OE = GetString("OE");
        model.OEID = GetString("OEID");
        model.Planner = GetString("Planner");
        model.PlannerID = GetString("PlannerID");
        model.ProjM = GetString("ProjM");
        model.ProjMID = GetString("ProjMID");
        model.ProgMID = GetString("ProgMID");
        model.ProgM = GetString("ProgM");
        model.Section = GetString("Section");
        model.SMID = GetString("SMID");
        model.SM = GetString("SM");
        model.DMID = GetString("DMID");
        model.DM = GetString("DM");
        model.DivMID = GetString("DivMID");
        model.DivM = GetString("DivM");
        model.DMEPID = GetString("DMEPID");
        model.DMEP = GetString("DMEP");
        model.FundingSourceID = GetString("FundingSourceID");
        model.FundingSource = GetString("FundingSource");
        model.ProjectTypeID = GetString("ProjectTypeID");
        model.ProjectType = GetString("ProjectType");
        model.ProblemStatement = GetString("ProblemStatement");
        model.ProblemStatementLong = GetString("ProblemStatementLong");
        model.CurrentScopeDefinition = GetString("CurrentScopeDefinition");
        model.CurrentScopeDefinitionLong = GetString("CurrentScopeDefinitionLong");
        model.Risk = GetString("Risk");
        model.RiskLong = GetString("RiskLong");
        model.Assumption = GetString("Assumption");
        model.AssumptionLong = GetString("AssumptionLong");
        model.BusinessDriver = GetString("BusinessDriver");
        model.RC = GetString("RC");
        model.RCID = GetString("RCID");
        model.Objective = GetString("Objective");
        model.CustomerNeed = GetString("CustomerNeed");
        model.CustomerNeedDate = GetDateTime("CustomerNeedDate");
        model.CustomerNeedID = GetString("CustomerNeedID");
        model.Phase = GetInt("Phase");
        model.PhaseDescription = GetString("PhaseDescription");
        model.PrimaryDiscipline = GetString("PrimaryDiscipline");
        model.ComplexityID = GetString("ComplexityID");
        model.PreviouslyApproved = GetInt("PreviouslyApproved");
        model.RequestedScope = GetInt("RequestedScope");
        model.VarianceComment = GetString("VarianceComment");
        model.CreatedBy = GetString("CreatedBy");
        model.Verifier = GetString("Verifier");
        model.VerifierID = GetString("VerifierID");
        model.InfoRef = GetString("InfoRef");
        model.Station = GetString("Station");
        model.Total = GetString("Total");
        model.Year1 = GetString("Year1");
        model.Internal1 = GetString("Internal1");
        model.External1 = GetString("External1");
        model.Year2 = GetString("Year2");
        model.Internal2 = GetString("Internal2");
        model.External2 = GetString("External2");
        model.PendingApprovers = GetString("PendingApprovers");
        model.Legacy = GetBool("Legacy");
        model.SDQUID = GetInt("SDQUID");
        model.LAMP3 = GetDecimal("LAMP3");
        model.HasP6 = GetInt("HasP6");
        model.SMApprovalDate = GetDateTime("SMApprovalDate");
        model.DMApprovalDate = GetDateTime("DMApprovalDate");
        model.DivMApprovalDate = GetDateTime("DivMApprovalDate");
        model.LAMP4 = GetString("LAMP4");
        model.LAMP4Baseline = GetString("LAMP4Baseline");
        model.SMAll = GetString("SMAll");
        model.RevisionHeader = GetString("RevisionHeader");
        model.DropdownFilter = GetString("DropdownFilter");
        model.IsEBS = GetBool("IsEBS");
        model.IsLeadPlanner = GetBool("IsLeadPlanner");

        return model;
    }

    public override void Write(Utf8JsonWriter writer, PCCMain value, JsonSerializerOptions options)
    {
        throw new NotImplementedException();
    }
}