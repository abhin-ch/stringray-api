using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.Common;

namespace StingrayNET.ApplicationCore.Interfaces;
public interface IUserEmailService
{
    public Task<CommonResult> GetUserEmailOptions(Procedure model);
    public Task<CommonResult> SaveUserEmailSelection(Procedure model);
}
