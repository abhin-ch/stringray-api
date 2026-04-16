using System.Collections.Generic;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models;

namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseStatus<T> where T : BaseDEDModel
{
    public string Name => _name;
    public List<BaseStatus<T>> Options { get; }
    public string StatusCode => _statusCode.ToString();

    protected T Row { get; } = null!;
    private string _name { get; set; } = string.Empty;
    private DEDStatusEnum _statusCode { get; set; }

    public BaseStatus(DEDStatusEnum statusCode, string name)
    {
        _statusCode = statusCode;
        _name = name;
    }

    public BaseStatus(T row)
    {
        Row = row;
        Options = new List<BaseStatus<T>>();
        NextStatus(row);
    }

    public BaseStatus()
    {
    }

    // Use this method to populate List<Options> of possible status options
    protected abstract void NextStatus(T row);
    protected abstract BaseStatus<T> CreateStatus(DEDStatusEnum statusCode, string label);

    protected void AddOption(DEDStatusEnum statusCode, string label)
    {
        var row = CreateStatus(statusCode, label);
        Options.Add(row);
    }

    protected void AddOptions(List<BaseStatus<T>> status)
    {
        Options.AddRange(status);
    }

}

public class UserRole
{
    public bool IsTOQAdmin { get; set; }
    public bool IsPCCAdmin { get; set; }
    public bool IsSysAdmin { get; set; }
    public bool IsVendor { get; set; }
    public List<string> BPRoles { get; set; }

    public bool HasRole(string role)
    {
        var foundRole = BPRoles.Find(e => e == role);
        return !string.IsNullOrEmpty(foundRole);
    }

}


