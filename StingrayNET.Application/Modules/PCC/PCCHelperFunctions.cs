using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.PCC;

public interface IPCCHelperFunctions
{
    Task<UserRole> GetUserRole(string employeeID);
}

public class PCCHelperFunctions : IPCCHelperFunctions
{
    readonly IRepositoryXL<PCCProcedure, PCCResult> _repository;
    public PCCHelperFunctions(IRepositoryXL<PCCProcedure, PCCResult> repository)
    {
        _repository = repository;
    }

    public async Task<UserRole> GetUserRole(string employeeID)
    {
        var roleResult = await _repository.Op_70(new PCCProcedure { EmployeeID = employeeID });
        var roles = DataParser.GetListFromData(roleResult.Data1, "BPRole");

        var userrole = new UserRole
        {
            BPRoles = DataParser.GetListFromData(roleResult.Data1, "BPRole"),
            IsSysAdmin = DataParser.GetValueFromData<bool>(roleResult.Data1, "IsSysAdmin"),
            IsTOQAdmin = DataParser.GetValueFromData<bool>(roleResult.Data1, "IsPCCAdmin"),
            IsVendor = DataParser.GetValueFromData<bool>(roleResult.Data1, "IsVendor")
        };

        return userrole;
    }


}