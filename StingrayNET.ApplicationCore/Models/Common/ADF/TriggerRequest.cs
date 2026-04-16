using System.Collections.Generic;
using StingrayNET.ApplicationCore.JsonConverters;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.Common.ADF;

public class TriggerRequest
{
    [JsonConverter(typeof(DictionaryJsonConverter))]
    public Dictionary<string, object>? Parameters { get; private set; }
    public string PipelineName { get; private set; }

    public bool? AlwaysUseProduction { get; private set; }

    public TriggerRequest(string pipelineName, Dictionary<string, object>? parameters = null, bool? alwaysUseProduction = false)
    {
        PipelineName = pipelineName;
        Parameters = parameters ?? new Dictionary<string, object>();
        AlwaysUseProduction = alwaysUseProduction;
    }

    public void AddParameter(string key, object value)
    {
        if (Parameters is { } && !Parameters.ContainsKey(key))
        {
            Parameters.Add(key, value);
        }
    }

    public void AddEmployeeID(string value)
    {
        if (Parameters is { } && !Parameters.ContainsKey("EmployeeID"))
        {
            Parameters.Add("EmployeeID", value);
        }
    }

    public void AddEmployeeID(int value)
    {
        if (Parameters is { } && !Parameters.ContainsKey("EmployeeID"))
        {
            Parameters.Add("EmployeeID", value.ToString());
        }
    }
}
