using System;
using System.Collections.Generic;
using System.Data;
using System.Text.Json;

#nullable disable
namespace StingrayNET.ApplicationCore.Models;
public class AppSecurityTable : DataTable
{
    public AppSecurityTable(object data)
    {
        InitTable();
        var result = JsonSerializer.Deserialize<IEnumerable<Privilege>>(Convert.ToString(data));
        foreach (var item in result)
        {
            AddRow(item);
        }
    }

    private void InitTable()
    {
        TableName = "stng.App_AppSecurity";
        Columns.Add(new DataColumn
        {
            ColumnName = "Module",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Name",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Type",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Description",
            DataType = typeof(string),
            MaxLength = 1000
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Location",
            DataType = typeof(string),
            MaxLength = 1000
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Endpoint",
            DataType = typeof(string),
            MaxLength = 255
        });
    }

    public void AddRow(Privilege privilege)
    {
        var row = NewRow();
        row["Module"] = privilege.Module;
        row["Name"] = privilege.Name;
        row["Description"] = privilege.Description;
        row["Type"] = privilege.Type;
        row["Location"] = privilege.Location;
        row["Endpoint"] = privilege.Endpoint;
        Rows.Add(row);
    }

    public class AppSecurity
    {
        public AppSecurity()
        {

            Endpoints = new List<EndpointTable.Endpoint>();
            Privileges = new List<AppSecurityTable.Privilege>();
        }
        public List<Privilege> Privileges { get; set; }
        public List<EndpointTable.Endpoint> Endpoints { get; set; }
    }

    public class Privilege
    {
        public string Module { get; set; }
        public string Name { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
#nullable enable
        public string? Location { get; set; } = null;
#nullable disable
        public string Endpoint { get; set; }
    }
}

#nullable enable