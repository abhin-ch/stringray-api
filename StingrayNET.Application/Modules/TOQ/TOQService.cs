using StingrayNET.Application.Modules.TOQ.Workflow;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.Requests.TOQ;
using StingrayNET.ApplicationCore.Specifications;

public interface ITOQService
{
    Task<List<BaseStatus<TOQModel>>> GetStatusOptions(TOQStatusOptionsRequest request);
    Task<BaseResult> FetchData(string employeeID, string type);
    Task GetVendorAssignedValidate(string uniqueID);
}

public class TOQService : ITOQService
{
    readonly IRepositoryL<Procedure, TOQResult> _repository;
    readonly ITOQStatusProvider _statusProvider;
    private readonly ITOQHelperFunctions _helperFunctions;

    public TOQService(IRepositoryL<Procedure, TOQResult> repository, ITOQStatusProvider statusProvider, ITOQHelperFunctions helperFunctions)
    {
        _repository = repository;
        _statusProvider = statusProvider;
        _helperFunctions = helperFunctions;
    }

    public async Task<BaseResult> FetchData(string employeeID, string type)
    {
        // Check if user is a Vendor (this can be done in DB in single request)
        var user = await _helperFunctions.GetUserRole(employeeID);


        // TODO: need to include other roles to fiter data on backend instead of frontend
        var model = new Procedure
        {
            EmployeeID = employeeID,
            Value1 = type,
            SubOp = 1,
            IsTrue1 = user.IsVendor // Add vendor filter if user is vendor
        };

        var result = await _repository.Op_05(model);

        return BaseResult.JsonResult<HttpSuccess>(result);
    }

    public async Task<List<BaseStatus<TOQModel>>> GetStatusOptions(TOQStatusOptionsRequest request)
    {
        var model = new TOQModel(request.TOQType, request.TMID, request.EmployeeID, request.StatusValue, _repository);
        model.User = await _helperFunctions.GetUserRole(request.EmployeeID);
        var status = _statusProvider.GetTOQStatusOptions(model);
        return status;
    }

    public Task GetVendorAssignedValidate(string uniqueID)
    {
        throw new NotImplementedException();
    }
}