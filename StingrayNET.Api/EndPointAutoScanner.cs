using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Routing;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using System.Text.Json;

#pragma warning disable CS8602 // Dereference of a possibly null reference.
namespace StingrayNET.Api;

public static class EndPointAutoScanner
{
    public static async Task ExecuteAsync(IServiceProvider serviceProvider)
    {
        var commonRepo = serviceProvider.GetRequiredService<IRepositoryM<Procedure, CommonResult>>();
        var appSecurity = Scan();

        // Insert into Stingray database
        var result = await commonRepo.Op_03(new Procedure { Value1 = JsonSerializer.Serialize(appSecurity.Endpoints), Value2 = JsonSerializer.Serialize(appSecurity.Privileges) });

        Console.WriteLine($"Endpoints found: ({appSecurity.Endpoints.Count}); Privileges found: ({appSecurity.Privileges.Count}); RowsAffected: ({result.RowsAffected})");


    }

    private static AppSecurityTable.AppSecurity Scan()
    {
        // Get all controllers in the API
        var controllers = Assembly.GetEntryAssembly()
            .GetTypes()
            .Where(t => t.IsSubclassOf(typeof(ControllerBase)));

        // Setup list of endpoints
        var appSecurity = new AppSecurityTable.AppSecurity();

        // Used to capture all privileges on the controllers to ensure a privilege has been added on the controller
        // for the duplicate privileges on endpoints
        var controllerPrivileges = new List<AppSecurityTable.Privilege>();

        // Scan each controller for methods and routes
        foreach (var controller in controllers)
        {
            var moduleName = controller.GetCustomAttribute<ModuleRouteAttribute>();
            var methods = controller.GetMethods()
                .Where(m => m.IsPublic && m.DeclaringType == controller);
            var appDetails = controller.GetCustomAttributes<AppSecurityAttribute>();

            appDetails.ToList().ForEach(a => controllerPrivileges.Add(new AppSecurityTable.Privilege { Name = a.Name, Module = moduleName.ModuleName, Description = controller.Name }));

            foreach (var method in methods)
            {
                var httpMethodAttributes = method.GetCustomAttributes<HttpMethodAttribute>();
                var routeAttributes = method.GetCustomAttributes<RouteAttribute>();
                var securityAttributes = method.GetCustomAttributes<AppSecurityAttribute>();
                foreach (var httpMethodAttribute in httpMethodAttributes)
                {
                    var httpMethod = httpMethodAttribute.HttpMethods.FirstOrDefault();
                    var endpoint = new EndpointTable.Endpoint
                    {
                        Method = httpMethod?.ToString(),
                        Module = moduleName?.ModuleName ?? "",
                        Route = $"{controller.Name.Replace("Controller", "").ToLower()}"
                    };

                    foreach (var routeAttribute in routeAttributes)
                    {
                        //Assuming the endpoint has only 1 route. Otherwise create new Endpoint instance and add to list.
                        endpoint.Route += $"/{routeAttribute.Template.ToLower()}";
                    }

                    if (securityAttributes.Count() > 0)
                    {
                        foreach (var privilegeAttribute in securityAttributes)
                        {
                            var privilege = new AppSecurityTable.Privilege
                            {
                                Module = endpoint.Module,
                                Name = privilegeAttribute.Name,
                                Type = privilegeAttribute.AppSecurityType,
                                Description = privilegeAttribute.Description,
                                Location = privilegeAttribute.Location,
                                Endpoint = endpoint.Key
                            };

                            var privilegeDetails = appDetails.FirstOrDefault(p => p.Name == privilegeAttribute.Name);
                            if (privilegeDetails != null)
                            {
                                privilege.Type = privilegeDetails.AppSecurityType;
                                privilege.Description = privilegeDetails.Description;
                                privilege.Location = privilegeDetails.Location;
                            }

                            appSecurity.Endpoints.Add(endpoint);
                            appSecurity.Privileges.Add(privilege);
                        }
                    }
                    else
                    {
                        appSecurity.Endpoints.Add(endpoint);
                    }

                }
            }
        }
        // Find duplicate Names in the privileges list        
        var duplicateNames = appSecurity.Privileges
        .GroupBy(p => new { p.Name, p.Module })
        .Where(g => g.Count() > 1)
        .Select(g => new { g.Key.Name, g.Key.Module })
        .ToList();

        // Filter out privileges where Name is a duplicate and not found on the controller    
        var filteredPrivileges = duplicateNames
        .Where(p => !controllerPrivileges.Any(a => a.Name == p.Name))
        .ToList();

        if (filteredPrivileges.Count > 0)
        {
            string error = $"EndPointAutoScanner: Module: {filteredPrivileges[0].Module} - Privilege: "
            + $"{filteredPrivileges[0].Name} - Duplicate privilege added but not assigned to the controller";
            throw new Exception(error);
        }

        appSecurity.Privileges = appSecurity.Privileges.Distinct().ToList();
        appSecurity.Endpoints = appSecurity.Endpoints.Distinct().ToList();
        return appSecurity;
    }
}

#pragma warning restore CS8602 // Dereference of a possibly null reference.