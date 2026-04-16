using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models;

public class DEDStatusConverter : JsonConverter<DEDStatus>
{
    public override DEDStatus Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        Dictionary<string, JsonElement>? dictionary = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(ref reader, options);
        var status = new DEDStatus();
        status.Status = dictionary?["Status"].GetString();
        status.Value = dictionary?["Value"].GetString();
        return status;
    }

    public override void Write(Utf8JsonWriter writer, DEDStatus value, JsonSerializerOptions options)
    {
        throw new NotImplementedException();
    }
}