using System;
using System.Collections.Generic;
using System.Data;
using System.Text.Json;

#nullable disable
namespace StingrayNET.ApplicationCore.Models.TWP;
public class GCATable : DataTable
{
    public GCATable(object data)
    {
        InitTable();
        try
        {
            var result = JsonSerializer.Deserialize<IEnumerable<GCActivity>>(Convert.ToString(data));
            foreach (var gc in result)
            {
                AddRow(gc);
            }
        }
        catch (Exception)
        {

        }

    }

    public GCATable(IEnumerable<GCActivity> details)
    {
        InitTable();
        foreach (var gc in details)
        {
            AddRow(gc);
        }
    }

    public GCATable()
    {
        InitTable();
    }

    private void InitTable()
    {
        TableName = "stngetl.TWP_TaskGChildUpdate";
        Columns.Add(new DataColumn
        {
            ColumnName = "PK_ID",
            DataType = typeof(string),
            MaxLength = 1000
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "PARENTCHILDTASKID",
            DataType = typeof(decimal),
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "PARENTTASKID",
            DataType = typeof(decimal),
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "ActivityName",
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
            ColumnName = "AssignedResource",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "StatusID",
            DataType = typeof(string),
            MaxLength = 1000
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "HardCopyReceived",
            DataType = typeof(bool),
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Labour",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "NumITPs",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Deleted",
            DataType = typeof(bool),
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "DeletedBy",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "DeletedDate",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "RAB",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "RAD",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "ITPNum",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "Discipline",
            DataType = typeof(string),
            MaxLength = 255
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "AssessingComp",
            DataType = typeof(bool),
        });
        Columns.Add(new DataColumn
        {
            ColumnName = "ReceivedDate",
            DataType = typeof(string),
            MaxLength = 255
        });
    }

    public void AddRow(GCActivity detail)
    {
        var row = NewRow();
        row["PK_ID"] = detail.PK_ID;
        row["PARENTCHILDTASKID"] = detail.PARENTCHILDTASKID;
        row["PARENTTASKID"] = detail.PARENTTASKID;
        row["ActivityName"] = detail.ActivityName;
        row["Type"] = detail.Type;
        row["AssignedResource"] = detail.AssignedResource;
        row["StatusID"] = detail.StatusID;
        row["HardCopyReceived"] = detail.HardCopyReceived;
        row["Labour"] = detail.Labour;
        row["NumITPs"] = detail.NumITPs;
        row["Deleted"] = 0;
        row["DeletedBy"] = "";
        row["DeletedDate"] = "";
        row["RAB"] = detail.RAB;
        row["RAD"] = detail.RAD;
        Rows.Add(row);
        row["ITPNum"] = detail.ITPNum;
        row["Discipline"] = detail.Discipline;
        row["AssessingComp"] = detail.AssessingComp;
        row["ReceivedDate"] = detail.ReceivedDate;
    }

    public class GCActivity
    {
        public string PK_ID { get; set; }
        public decimal PARENTCHILDTASKID { get; set; }
        public decimal PARENTTASKID { get; set; }
        public string ActivityName { get; set; }
        public string Type { get; set; }
        public string AssignedResource { get; set; }
        public string StatusID { get; set; }
        public bool HardCopyReceived { get; set; }
        public string Labour { get; set; }
        public string NumITPs { get; set; }

        public string RAD { get; set; }

        public string RAB { get; set; }

        public bool Deleted { get; set; }

        public string DeletedBy { get; set; }

        public string DeletedDate { get; set; }

        public string ITPNum { get; set; }

        public string Discipline { get; set; }

        public bool AssessingComp { get; set; }
        public string ReceivedDate { get; set; }
    }
}

#nullable enable