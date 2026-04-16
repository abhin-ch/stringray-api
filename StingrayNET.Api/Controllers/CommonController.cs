using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[ModuleRoute("api/[controller]", ModuleEnum.Common)]
public class CommonController : BaseApiController
{
    private readonly IRepositoryM<Procedure, CommonResult> _repository;
    private readonly ICacheProvider _cache;

    public CommonController(IRepositoryM<Procedure, CommonResult> repository, IIdentityService identityService, ICacheProvider cache) : base(identityService)
    {
        _repository = repository;
        _cache = cache;
    }

    //GET api/common/value-label?module={param1}&resultSet={param2}&fieldName={param3}
    [HttpGet]
    [Route("value-label")]
    public async Task<JsonResult> GetValueLabel([FromQuery] Procedure model)
    {
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/[controller]/blackout-dates
    [HttpGet]
    [Route("blackout-dates")]
    public async Task<JsonResult> GetBlackoutDates()
    {
        var result = await _repository.Op_02();
        return BaseResult.JsonResult(result);
    }

    //GET api/common/maximo-url
    [HttpGet]
    [Route("maximo-url")]
    public async Task<JsonResult> GetMaximoURL(string type, string number)
    {
        var result = await _repository.Op_06(new Procedure { Value1 = type, Value2 = number });
        return BaseResult.JsonResult(result);
    }

    //GET api/common/value-labels
    [HttpGet]
    [Route("value-labels")]
    public async Task<JsonResult> GetAllValueLabel()
    {
        var result = await _repository.Op_07();
        return BaseResult.JsonResult(result);
    }

    //POST api/common/data-refresh
    [HttpPost]
    [Route("data-refresh")]
    public async Task<JsonResult> DataRefresh([FromBody] Procedure model)
    {
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/common/mention-users
    [HttpGet]
    [Route("mention-users")]
    public async Task<JsonResult> GetMentionUsers()
    {
        var result = await _repository.Op_10();
        return BaseResult.JsonResult(result);
    }

    //GET api/common/users
    [HttpGet]
    [Route("users")]
    public async Task<JsonResult> GetUserOptions()
    {
        string cacheKey = $"common_users";
        //check if data cached
        if (!_cache.TryGet(cacheKey, out CommonResult result))
        {
            //get result and cache
            result = await _repository.Op_11();
            _cache.Set(cacheKey, result);
        }
        return BaseResult.JsonResult(result);
    }

    //POST api/common/user-dynamic
    [HttpPost]
    [Route("user-dynamic")]
    public async Task<JsonResult> UserDynamic([FromBody] Procedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/common/user-dynamic-verify
    [HttpPost]
    [Route("user-dynamic-verify")]
    public async Task<JsonResult> UserDynamicVerify([FromBody] Procedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/common/ws/token
    [HttpPost]
    [Route("ws/token")]
    public async Task<JsonResult> GetToken(Procedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_15(model));
    }

    //POST api/common/sections
    //Value1 (Division) and Value2 (Department) are optional
    [HttpPost]
    [Route("sections")]
    public async Task<JsonResult> GetSections([FromBody] Procedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/common/email-option
    //Required - Module 
    [HttpPost]
    [Route("email-option")]
    public async Task<JsonResult> GetEmailOptions([FromBody] Procedure model)
    {
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/common/user-email
    [HttpPatch]
    [Route("user-email")]
    public async Task<JsonResult> EditUserEmailOptions([FromBody] Procedure model)
    {
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

}