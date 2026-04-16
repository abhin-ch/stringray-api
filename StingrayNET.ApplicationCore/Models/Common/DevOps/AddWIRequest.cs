using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Text.Json;

namespace StingrayNET.ApplicationCore.Models.Common.DevOps;

public class AddWIRequest
{
    public List<AddWISubrequest>? AddWISubrequests { get; }
    public string? WIType { get; }
    public string? Module { get; }

    private static readonly Dictionary<string, string> PermittedWITypes = new Dictionary<string, string>()
        {
            {@"bug","Bug"},
            {@"userstory","User Story"},
            {@"epic","Epic"},
            {@"userstorygeneral", "User Story"}
        };

    public AddWIRequest(string WIType, string module, List<AddWISubrequest> addWISubrequests)
    {
        //WI Type
        WIType = Regex.Replace(WIType, @"\s", string.Empty);
        if (!WITypeComparison(WIType))
        {
            throw new ArgumentOutOfRangeException(@"WIType", string.Format(@"{0} is not an accepted WI type"));
        }

        this.WIType = PermittedWITypes[WIType];

        Module = module;
        AddWISubrequests = addWISubrequests;
    }

    private static bool WITypeComparison(string WIType)
    {
        return (PermittedWITypes.ContainsKey(WIType));
    }

}
