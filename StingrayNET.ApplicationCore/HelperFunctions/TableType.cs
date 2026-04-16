using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text.Json;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.HelperFunctions;

public class TableType<T> : DataTable where T : BaseTableType
{
    public TableType(object data)
    {
        InitTable();
        try
        {
            var json = Convert.ToString(data);
            if (json is not null)
            {
                var result = JsonSerializer.Deserialize<List<T>>(json);
                if (result is not null)
                {
                    SetTableName(result.FirstOrDefault());
                    foreach (var item in result)
                    {
                        AddRow(item);
                    }
                }
            }
        }
        catch
        (Exception e)
        {
            // Handle deserialization error
            Console.WriteLine($"{typeof(T).Name} deserialization error: {e.Message}");
            throw e;
        }
    }
    public TableType(IEnumerable<T> details)
    {
        InitTable();
        SetTableName(details.FirstOrDefault());
        foreach (var item in details)
        {
            AddRow(item);
        }
    }
    public TableType()
    {
        InitTable();
    }
    private void InitTable()
    {
        PropertyInfo[] properties = typeof(T).GetProperties();
        foreach (PropertyInfo property in properties)
        {
            if (property.Name == nameof(BaseTableType.TableName))
            {
                continue;
            }
            DataColumn column = new DataColumn
            {
                ColumnName = property.Name,
                DataType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType
            };
            Columns.Add(column);
        }
    }
    public void AddRow(T? detail)
    {
        if (detail is null) return;

        var row = NewRow();
        foreach (DataColumn column in Columns)
        {
            row[column.ColumnName] = detail.GetType().GetProperty(column.ColumnName)?.GetValue(detail, null) ?? DBNull.Value;
        }
        Rows.Add(row);
    }
    public void SetTableName(T? detail)
    {
        if (detail is null) return;
        TableName = detail.TableName;
    }
}