using StingrayNET.ApplicationCore.Abstractions;
using System;
namespace StingrayNET.ApplicationCore.Models.TableTypes;

public class Common : BaseTableType
{
    public override string TableName => "stng.Common_TableType";
    public string EmployeeID { get; set; }
    public string Value1 { get; set; }
    public string Value2 { get; set; }
    public string Value3 { get; set; }
    public string Value4 { get; set; }
    public string Value5 { get; set; }
    public string Value6 { get; set; }
    public int Num1 { get; set; }
    public int Num2 { get; set; }
    public int Num3 { get; set; }
    public int Num4 { get; set; }
    public DateTime Date1 { get; set; }
    public DateTime Date2 { get; set; }
    public bool IsTrue1 { get; set; }
    public bool IsTrue2 { get; set; }

}
