using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models;
using System;
namespace StingrayNET.ApplicationCore.Specifications;
[AttributeUsage(AttributeTargets.Class)]
public class ModuleRouteAttribute : RouteAttribute
{
    public string? ModuleName { get; }
    public ModuleRouteAttribute(string template, ModuleEnum module) : base(template)
    {
        ModuleName = Enum.GetName(typeof(ModuleEnum), module);
    }
}