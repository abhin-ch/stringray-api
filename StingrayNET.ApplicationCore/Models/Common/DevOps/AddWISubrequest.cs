using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace StingrayNET.ApplicationCore.Models.Common.DevOps;

public class AddWISubrequest
{
    public string op { get; }
    public string? path { get; }
    public string? from { get; } = string.Empty;
    public string? value { get; }

    private static readonly List<string> PermittedOps = new List<string>()
        {
            @"add"
        };

    public AddWISubrequest(string op, string path, string value)
    {
        //Op
        if (!PermittedOps.Contains(op))
        {
            throw new ArgumentOutOfRangeException(@"op", string.Format(@"{0} is not a valid option for op", op));
        }

        this.op = op;

        //Path
        if (!Regex.IsMatch(path, @"\/fields"))
        {
            path = string.Format(@"/fields/{0}", path);
        }

        this.path = path;

        //Everything else
        this.value = value;
    }
}

