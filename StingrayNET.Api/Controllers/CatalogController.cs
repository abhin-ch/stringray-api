using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Catalog;
using StingrayNET.ApplicationCore.Models.Common;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
[Authorize]
public class CatalogController : ControllerBase
{
    private readonly IRepositoryS<Procedure, CatalogResult> _repository;
    private readonly IIdentityService _identityService;

    public CatalogController(IRepositoryS<Procedure, CatalogResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;

    }

    //GET /api/Catalog/modules
    [Route("modules")]
    [HttpGet]
    public async Task<JsonResult> Op_1()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //POST api/Catalog/module-request
    //OUTDATED--refer to api/admin/request
    [HttpPost]
    [Route("module-request")]
    public async Task<JsonResult> CreateModuleRequest([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET /api/Catalog/module-owners
    [Route("module-owners")]
    [HttpGet]
    public async Task<JsonResult> GetModuleOwners()
    {
        var result = await _repository.Op_03();
        return BaseResult.JsonResult(result);
    }

    //POST /api/Catalog/module-owner
    //Required: Value1 (module name)
    [Route("module-owner")]
    [HttpPost]
    public async Task<JsonResult> GetModuleOwner([FromBody] Procedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }


}
