
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Admin;

public class AzureADTable : BaseTableType
{
    public override string TableName => "stng.Admin_User";

    public string EmployeeID { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public string Title { get; set; }
    public string LANID { get; set; }
    public string UserPrincipleName { get; set; }
}

