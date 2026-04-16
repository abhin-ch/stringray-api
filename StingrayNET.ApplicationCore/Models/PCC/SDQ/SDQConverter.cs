using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.PCC.SDQ;

public class SDQConverter : JsonConverter<SDQModel>
{
    public override SDQModel Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        Dictionary<string, JsonElement>? dictionary = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(ref reader, options);
        var sdq = new SDQModel();



        return sdq;
    }

    public override void Write(Utf8JsonWriter writer, SDQModel value, JsonSerializerOptions options)
    {
        throw new NotImplementedException();
    }
}