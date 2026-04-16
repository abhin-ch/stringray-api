using StingrayNET.ApplicationCore.Interfaces;
using System;
using System.Collections.Generic;
using System.Data;
using System.Text.Json;

namespace StingrayNET.ApplicationCore.Models.CARLA;
public class ScheduleTable<T> : DataTable where T : IFADetails
{
    public ScheduleTable(string data)
    {
        InitTable();
        var result = JsonSerializer.Deserialize<IEnumerable<T>>(data);
        if (result != null)
            foreach (var item in result)
            {
                item.MapFields();
                AddRow(item);
            }
    }
    public ScheduleTable()
    {
        InitTable();
    }

    private void InitTable()
    {
        TableName = "stng.CARLA_FADetails";
        Columns.Add(new DataColumn
        {
            ColumnName = "ActivityID",
            DataType = typeof(string),
            MaxLength = 20
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "DetailName",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "DetailValue",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "DetailValue1",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "DetailValue2",
            DataType = typeof(string),
            MaxLength = 255
        });
    }

    public void AddRow(T schedule)
    {
        var row = NewRow();
        row["ActivityID"] = schedule.ActivityID;
        row["DetailName"] = schedule.DetailName;
        row["DetailValue"] = schedule.DetailValue;
        row["DetailValue1"] = schedule.DetailValue1;
        Rows.Add(row);
    }

}

public class ScheduleUpdate : IFADetails
{
    public string? NewValue { get; set; }
    public string? Type { get; set; }
    public string? Actualized { get; set; }
    public override void MapFields()
    {
        DetailValue = NewValue;
        DetailName = Type;
        DetailValue1 = Actualized;
    }
}

public class SubFragnetList : IFADetails
{
    public int? FragnetID { get; set; }

    public override void MapFields()
    {
        DetailValue = FragnetID.ToString();
    }
}
