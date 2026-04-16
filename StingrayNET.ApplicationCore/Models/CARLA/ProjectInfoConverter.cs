using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.CARLA;

public class ProjectInfoConverter : JsonConverter<ScheduleUpdateEmail.Project>
{
    public override ScheduleUpdateEmail.Project Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        Dictionary<string, JsonElement>? dictionary = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(ref reader, options);
        var scheduleUpdate = new ScheduleUpdateEmail.Project();
        scheduleUpdate.Planner = dictionary?["Planner"].GetString();
        scheduleUpdate.PlannerLANID = dictionary?["PlannerLANID"].GetString();
        scheduleUpdate.PlannerEmail = dictionary?["PlannerEmail"].GetString();
        scheduleUpdate.ProjectID = dictionary?["ProjectID"].GetString();
        scheduleUpdate.PMLANID = dictionary?["PMLANID"].GetString();
        scheduleUpdate.PMEmail = dictionary?["PMEmail"].GetString();
        scheduleUpdate.PM = dictionary?["PM"].GetString();
        scheduleUpdate.ProjectName = dictionary?["ProjectName"].GetString();
        scheduleUpdate.CommitmentOwner = dictionary?["CommitmentOwner"].GetString();
        scheduleUpdate.CommitmentOwnerLANID = dictionary?["CommitmentOwnerLANID"].GetString();
        scheduleUpdate.CommitmentOwnerEmail = dictionary?["CommitmentOwnerEmail"].GetString();
        scheduleUpdate.ContractAdmin = dictionary?["ContractAdmin"].GetString();
        scheduleUpdate.ContractAdminLANID = dictionary?["ContractAdminLANID"].GetString();
        scheduleUpdate.ContractAdminEmail = dictionary?["ContractAdminEmail"].GetString();
        scheduleUpdate.FragnetName = dictionary?["FragnetName"].GetString();
        scheduleUpdate.Reason = dictionary?["Reason"].GetString();
        scheduleUpdate.Status = dictionary?["Status"].GetString();
        return scheduleUpdate;
    }

    public override void Write(Utf8JsonWriter writer, ScheduleUpdateEmail.Project value, JsonSerializerOptions options)
    {
        throw new NotImplementedException();
    }
}