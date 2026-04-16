using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.Comment;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[ModuleRoute("api/[controller]", ModuleEnum.Common)]
public class CommentController : BaseApiController
{
    private readonly IRepositoryS<Procedure, CommentResult> _repository;

    public CommentController(IRepositoryS<Procedure, CommentResult> repository, IIdentityService identityService) : base(identityService)
    {
        _repository = repository;
    }

    //GET api/comment
    [HttpGet]
    public async Task<JsonResult> GetComments(string parentID, string parentTable, string? relatedTable, string? relatedID)
    {
        var model = new Procedure
        {
            Value1 = parentID,
            Value2 = parentTable,
            Value3 = relatedTable,
            Value4 = relatedID,
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
        };
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/comment/related
    [HttpGet]
    [Route("related")]
    public async Task<JsonResult> GetRelatedComments(string parentID, string relatedTable)
    {
        var model = new Procedure
        {
            Value1 = parentID,
            Value2 = relatedTable,
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
        };
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/comment
    [HttpPost]
    public async Task<JsonResult> AddComment([FromBody] Procedure body)
    {
        if (String.IsNullOrEmpty(body.Value1))
        {
            return BaseResult.JsonResult<HttpError>("ParentID must be defined on Value1");
        }
        body.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var note = await _repository.Op_01(body);
        return BaseResult.JsonResult(note);
    }

    //PUT api/comment
    [HttpPut]
    public async Task<JsonResult> EditComment([FromBody] Procedure body)
    {
        if (!body.Num1.HasValue)
        {
            return BaseResult.JsonResult<HttpError>("CID must be defined on Num1");
        }
        body.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var note = await _repository.Op_04(body);
        return BaseResult.JsonResult(note);
    }

    [Route("pin")]
    [HttpPut]
    public async Task<JsonResult> PinComment([FromBody] Procedure body)
    {
        if (!body.Num1.HasValue)
        {
            return BaseResult.JsonResult<HttpError>("CID must be defined on Num1");
        }
        body.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var note = await _repository.Op_03(body);
        return BaseResult.JsonResult(note);
    }

    //DELETE api/comment
    [HttpDelete]
    public async Task<JsonResult> DeleteComment([FromBody] Procedure body)
    {
        if (!body.Num1.HasValue)
        {
            return BaseResult.JsonResult<HttpError>("CID must be defined on Num1");
        }
        body.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var note = await _repository.Op_02(body);
        return BaseResult.JsonResult(note);
    }
}