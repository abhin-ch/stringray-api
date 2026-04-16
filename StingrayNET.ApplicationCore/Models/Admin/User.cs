namespace StingrayNET.ApplicationCore.Models.Admin;

public class User
{
    public string JobTitle { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string EmployeeID { get; set; }
    public string UserPrincipalName { get; set; } = string.Empty;
    public string LANID { get; set; } = string.Empty;
    public string WorkGroup { get; set; } = string.Empty;
}