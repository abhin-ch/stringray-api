using System.Data;

namespace StingrayNET.ApplicationCore.Models.Feedback;

public class Resource : DataTable
{
    private const int MAX_IMAGE_SIZE = 10000;

    public Resource()
    {
        Columns.Add(new DataColumn
        {
            DataType = typeof(string),
            MaxLength = 20,
            ColumnName = "FileType"

        });
        Columns.Add(new DataColumn
        {
            DataType = typeof(byte[]),
            ColumnName = "ImageContent"
        });
    }

    public void AddResource(string type, byte[] image)
    {
        var row = NewRow();
        row["FileType"] = type;
        row["ImageContent"] = image;
        Rows.Add(row);
    }
}