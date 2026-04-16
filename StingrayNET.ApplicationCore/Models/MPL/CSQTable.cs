using System.Data;

namespace StingrayNET.ApplicationCore.Models.MPL;

public class CSQTable : DataTable
{
    public CSQTable()
    {
        InitTable();
    }

    private void InitTable()
    {
        TableName = "stng"; // TODO get table name
        Columns.Add(new DataColumn
        {
            ColumnName = "FragnetID",
            DataType = typeof(int),
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "FragnetName",
            DataType = typeof(string),
            MaxLength = 255
        });
    }

    public class CSQ
    {
        public int FragnetID { get; init; }
        public string FragnetName { get; init; }
    }
}