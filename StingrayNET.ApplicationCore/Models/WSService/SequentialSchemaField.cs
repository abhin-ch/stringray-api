using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.WSService;
public enum SequentialSchemaFieldType
{
    Number = 1,
    String = 2,
    Boolean = 3,
    DateTime = 4
}

public class SequentialSchemaField
{
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public SequentialSchemaFieldType Type { get; private set; }

    public string Name { get; private set; }

    public SequentialSchemaField(SequentialSchemaFieldType type, string name)
    {
        Name = name;
        Type = type;
    }

}
