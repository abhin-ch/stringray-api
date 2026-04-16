using System;
using System.Collections.Generic;
using System.Data;
using System.Text.Json;

#nullable disable
namespace StingrayNET.ApplicationCore.Models;
public class EndpointTable : DataTable
{
    public EndpointTable(object data)
    {
        InitTable();
        var result = JsonSerializer.Deserialize<IEnumerable<Endpoint>>(Convert.ToString(data));
        foreach (var item in result)
        {
            AddRow(item);
        }
    }

    private void InitTable()
    {
        TableName = "stng.App_Endpoint";
        Columns.Add(new DataColumn
        {
            ColumnName = "Module",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "RouteName",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Method",
            DataType = typeof(string),
            MaxLength = 255
        });
    }

    public void AddRow(Endpoint endpoint)
    {
        var row = NewRow();
        row["Module"] = endpoint.Module;
        row["RouteName"] = endpoint.Route;
        row["Method"] = endpoint.Method;
        Rows.Add(row);
    }

    public class Endpoint
    {
        public string Module { get; set; }
        public string Route { get; set; }
        public string Method { get; set; }
        public string Key => $"{Module}/{Route}/{Method.ToUpper()}";
    }
}

#nullable enable