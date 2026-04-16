using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;

public interface IAdminHelperFunctions
{
    Task<AdminResult> GetUserDetails(string? employeeID);
    Task AccessRequestEmail(AdminProcedure model);
}

public class AdminHelperFunctions : IAdminHelperFunctions
{

    readonly IRepositoryXL<AdminProcedure, AdminResult> _repository;
    readonly IRepositoryM<Procedure, DelegateResult> _DelegateRepository;
    readonly IAdminSingletonService _singletonService;
    readonly IHttpContextAccessor _httpContextAccessor;
    public AdminHelperFunctions(IRepositoryXL<AdminProcedure, AdminResult> repository, IHttpContextAccessor httpContextAccessor, IAdminSingletonService singletonService, IRepositoryM<Procedure, DelegateResult> delegateRepository)
    {
        _DelegateRepository = delegateRepository;
        _repository = repository;
        _singletonService = singletonService;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task AccessRequestEmail(AdminProcedure model)
    {

        User? originalUser = (User)_httpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"];
        bool impersonating = _httpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS");

        await _singletonService.SendEmail(model, originalUser, impersonating);

    }

    public async Task<AdminResult> GetUserDetails(string? employeeID)
    {

        //Get 'me' details
        Task<AdminResult> meTask = _repository.Op_51();

        //get permissions
        Task<AdminResult> permissionsTask = _repository.Op_56();

        //get roles
        Task<AdminResult> rolesTask = _repository.Op_34();

        //get attributes
        Task<AdminResult> attributesTask = _repository.Op_75();

        //get endpoints
        Task<AdminResult> endpointsTask = _repository.Op_76();

        //get delegates
        var model = new Procedure
        {
            EmployeeID = employeeID
        };
        Task<DelegateResult> delegateTask = _DelegateRepository.Op_19(model);

        //(eventually?) get modules

        //await all tasks
        await Task.WhenAll(meTask, permissionsTask, rolesTask, attributesTask, endpointsTask, delegateTask);

        //assign data
        AdminResult meData = meTask.Result;
        AdminResult permissionsData = permissionsTask.Result;
        AdminResult rolesData = rolesTask.Result;
        AdminResult attributesData = attributesTask.Result;
        AdminResult endpointsData = endpointsTask.Result;
        DelegateResult delegatesData = delegateTask.Result;

        AdminResult finalResult = new AdminResult
        {
            Data1 = meData.Data1,
            permissions = permissionsData.Data1,
            roles = rolesData.Data1,
            attributes = attributesData.Data1,
            endpoints = endpointsData.Data1,
            delegates = delegatesData.Data1
        };

        return finalResult;
    }
}