using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.CARLA;

public class ActivityConverter : JsonConverter<ScheduleUpdateEmail.Activity>
{
    public override ScheduleUpdateEmail.Activity Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        Dictionary<string, JsonElement>? dictionary = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(ref reader, options);
        var activity = new ScheduleUpdateEmail.Activity(); 
        activity.ActivityID = dictionary?["ActivityID"].GetString();
        activity.Title = dictionary?["Title"].GetString();
        activity.CommitmentDate = dictionary?["CommitmentDate"].GetString();
        activity.Resource = dictionary?["Resource"].GetString();
        activity.RevisedDate = dictionary?["RevisedDate"].GetString();
        activity.NCSQ = dictionary?["NCSQ"].GetString();
        return activity;
    }

    public override void Write(Utf8JsonWriter writer, ScheduleUpdateEmail.Activity value, JsonSerializerOptions options)
    {
        throw new NotImplementedException();
    }
}