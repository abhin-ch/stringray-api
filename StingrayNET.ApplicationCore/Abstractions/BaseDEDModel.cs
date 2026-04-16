using System;
using StingrayNET.ApplicationCore.Models;

namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseDEDModel
{
    public abstract string Type { get; }
    public int? ID { get; set; } = null!;
    public DEDStatusEnum StatusCode { get; set; }
    public string StatusCodeString => Enum.GetName<DEDStatusEnum>(StatusCode) ?? string.Empty;
    public UserRole? User { get; set; }
    public abstract bool IsAdmin { get; }


}