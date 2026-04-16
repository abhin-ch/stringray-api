using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Models.Admin;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IIdentityService
{
    public Task<string> GetEmployeeID(HttpContext context, bool forceQuery = false);
    public Task<string> GetOriginalEmployeeID(HttpContext context);
    public Task<Models.Admin.User> GetOriginalUser(HttpContext context);
    public Task<ApplicationCore.Models.Admin.User> GetUser(HttpContext context, bool forceQuery = false);
    public Task<string> GetEmail(HttpContext context, string lanid);
    public Task<bool> ImpersonateCheck(HttpContext context, IRepositoryXL<AdminProcedure, AdminResult> repository);
    public Task<bool> EndImpersonation(HttpContext context);

}
