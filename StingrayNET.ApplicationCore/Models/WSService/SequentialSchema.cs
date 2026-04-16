using System.Text.Json.Serialization;
using System.Collections.Generic;
using System;
using System.Linq;

namespace StingrayNET.ApplicationCore.Models.WSService;
public enum SequentialMessageType
{
    JSON = 1,
    Binary = 2,
    Text = 3,
    Number = 4
}

public class SequentialSchema
{
    public uint StageID { get; private set; }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public SequentialMessageType Expect { get; private set; }

    [JsonConverter(typeof(JsonStringEnumConverter))]
    public SequentialMessageType Response { get; private set; }

    public List<SequentialSchemaField>? JsonFields { get; private set; }

    public bool StageLoop { get; private set; }

    [JsonConstructor]
    public SequentialSchema(uint stageID, SequentialMessageType expect, SequentialMessageType response, bool loopStage, List<SequentialSchemaField>? jsonFields = null)
    {
        StageID = stageID;
        Expect = expect;
        Response = response;
        JsonFields = jsonFields;
        StageLoop = loopStage;
    }

    public SequentialSchema(List<Dictionary<string, object>> stageData)
    {
        //Stage-Level Data First
        var stage = stageData[0];

        //StageID
        if (!stage.ContainsKey(@"StageID"))
        {
            throw new ArgumentException($"StageID not included in provided Stage metadata");
        }

        StageID = (uint)Convert.ToInt32(stage[@"StageID"]);

        //LoopStage
        if (!stage.ContainsKey(@"StageLoop"))
        {
            throw new ArgumentException($"LoopStage not included in provided Stage metadata");
        }

        StageLoop = Convert.ToBoolean(stage[@"StageLoop"]);

        //Expect
        SequentialMessageType expect;
        if (!stage.ContainsKey(@"Expect"))
        {
            throw new ArgumentException($"Expect not included in provided Stage metadata");
        }

        else if (Enum.TryParse(stage[@"Expect"].ToString(), true, out expect))
        {
            Expect = expect;
        }

        else
        {
            throw new ArgumentException($"Provided value of Expect ({stage[@"Expect"].ToString()}) cannot be parsed");
        }

        //Response
        SequentialMessageType response;
        if (!stage.ContainsKey(@"Response"))
        {
            throw new ArgumentException($"Response not included in provided Stage metadata");
        }

        else if (Enum.TryParse(stage[@"Response"].ToString(), true, out response))
        {
            Response = response;
        }

        else
        {
            throw new ArgumentException($"Provided value of Response ({stage[@"Response"].ToString()}) cannot be parsed");
        }

        //If Expect type is JSON, check if there are specified JSON fields
        if (Expect == SequentialMessageType.JSON)
        {
            //Check if "Field" and "Type" fields exist in fieldData
            if (!stage.ContainsKey(@"FieldName") || !stage.ContainsKey(@"FieldType"))
            {
                throw new ArgumentException(@"FieldName and/or FieldType not included in provided Stage metadata");
            }

            List<SequentialSchemaField> fields = new List<SequentialSchemaField>();
            foreach (var fieldRow in stageData)
            {
                SequentialSchemaFieldType type;
                if (Enum.TryParse(fieldRow[@"FieldType"].ToString(), true, out type))
                {
                    fields.Add(new SequentialSchemaField(type, fieldRow[@"FieldName"].ToString()));
                }

                else
                {
                    throw new ArgumentException($"Provided value of Type ({fieldRow[@"FieldType"].ToString()}) cannot be parsed");
                }

            }

            JsonFields = fields;

        }

    }

    public static List<SequentialSchema> Build(List<Dictionary<string, object>> metadata)
    {
        //Declare return list
        List<SequentialSchema> returnList = new List<SequentialSchema>();

        //Get all unique stages
        List<uint> uniqueStages = metadata.Select(x => (uint)Convert.ToInt32(x[@"StageID"])).Distinct().ToList();

        //Loop through unique stage metadata sets, create SequentialSchema objects, and add to return list
        foreach (uint uniqueStage in uniqueStages)
        {
            returnList.Add(new SequentialSchema(metadata.Where(x => ((uint)Convert.ToInt32(x[@"StageID"])) == uniqueStage).ToList()));
        }

        return returnList;
    }

}
