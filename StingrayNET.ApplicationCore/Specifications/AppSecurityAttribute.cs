using StingrayNET.ApplicationCore.Models;
using System;

namespace StingrayNET.ApplicationCore.Specifications;
[AttributeUsage(AttributeTargets.Method | AttributeTargets.Class, AllowMultiple = true)]
public class AppSecurityAttribute : Attribute
{
    public string? Name { get; }
    public string? AppSecurityType { get; }
    public string? Description { get; }
    public string? Location { get; }
    public AppSecurityAttribute(string name, AppSecurityTypeEnum appSecurityType, string description, string? location = null)
    {
        Name = name;
        AppSecurityType = Enum.GetName(typeof(AppSecurityTypeEnum), appSecurityType);
        Description = description;
        Location = location;
    }

    public AppSecurityAttribute(string name)
    {
        Name = name;
    }
}
