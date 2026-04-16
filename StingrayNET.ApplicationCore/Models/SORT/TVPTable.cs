using System.Data;

namespace StingrayNET.ApplicationCore.Models.SORT;
public class TVPTable : DataTable
{

    public TVPTable()
    {
        InitTable();
    }

    private void InitTable()
    {
        TableName = "stng"; // TODO get table name
        Columns.Add(new DataColumn
        {
            ColumnName = "Value",
            DataType = typeof(string),
            MaxLength = 20
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Type",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Del",
            DataType = typeof(bool),
        });
    }

    public class TVPTag
    {
        public string Value { get; init; }
        public string Type { get; init; }
        public bool Del { get; init; }
    }
}
