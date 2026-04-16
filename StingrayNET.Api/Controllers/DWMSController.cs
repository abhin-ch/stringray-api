using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.DWMS;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.DWMS)]
[ApiController]
public class DWMSController : ControllerBase
{
    private readonly IRepositoryL<DWMSProcedure, DWMSResult> _repository;

    public DWMSController(IRepositoryL<DWMSProcedure, DWMSResult> repository)
    {
        _repository = repository;
    }

    //GET api/dwms/job
    [HttpGet]
    [Route("job")]
    public async Task<JsonResult> GetJob()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //POST api/dwms/job
    [HttpPost]
    [Route("job")]
    public async Task<JsonResult> AddJob([FromBody] DWMSProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/dwms/job
    [HttpPatch]
    [Route("job")]
    public async Task<JsonResult> EditJob([FromBody] DWMSProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/comment
    [HttpGet]
    [Route("comment")]
    public async Task<JsonResult> GetComment()
    {
        var result = await _repository.Op_04();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/comment
    [HttpPut]
    [Route("comment")]
    public async Task<JsonResult> AddComment([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/comment
    [HttpDelete]
    [Route("comment")]
    public async Task<JsonResult> DeleteComment([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //PATCHs api/dwms/comment
    [HttpPatch]
    [Route("comment")]
    public async Task<JsonResult> EditComment([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/status
    [HttpGet]
    [Route("status")]
    public async Task<JsonResult> GetStatus()
    {
        var result = await _repository.Op_08();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/status
    [HttpPut]
    [Route("status")]
    public async Task<JsonResult> AddStatus([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/status
    [HttpDelete]
    [Route("status")]
    public async Task<JsonResult> DeleteStatus([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/source
    [HttpGet]
    [Route("source")]
    public async Task<JsonResult> GetSource()
    {
        var result = await _repository.Op_11();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/source
    [HttpPut]
    [Route("source")]
    public async Task<JsonResult> AddSource([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/source
    [HttpDelete]
    [Route("source")]
    public async Task<JsonResult> DeleteSource([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/type
    [HttpGet]
    [Route("type")]
    public async Task<JsonResult> GetType()
    {
        var result = await _repository.Op_14();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/type
    [HttpPut]
    [Route("type")]
    public async Task<JsonResult> AddType([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/type
    [HttpDelete]
    [Route("type")]
    public async Task<JsonResult> DeleteType([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/subjob
    [HttpGet]
    [Route("subjob")]
    public async Task<JsonResult> GetSubJob()
    {
        var result = await _repository.Op_17();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/subjob
    [HttpPut]
    [Route("subjob")]
    public async Task<JsonResult> AddSubJob([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/subjob
    [HttpDelete]
    [Route("subjob")]
    public async Task<JsonResult> DeleteSubJob([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/category
    [HttpGet]
    [Route("category")]
    public async Task<JsonResult> GetCategory()
    {
        var result = await _repository.Op_20();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/category
    [HttpPut]
    [Route("category")]
    public async Task<JsonResult> AddCategory([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/category
    [HttpDelete]
    [Route("category")]
    public async Task<JsonResult> DeleteCategory([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/disciple
    [HttpGet]
    [Route("disciple")]
    public async Task<JsonResult> GetDisciple()
    {
        var result = await _repository.Op_23();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/disciple
    [HttpPut]
    [Route("disciple")]
    public async Task<JsonResult> AddDisciple([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/disciple
    [HttpDelete]
    [Route("disciple")]
    public async Task<JsonResult> DeleteDisciple([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/dwms/unit
    [HttpGet]
    [Route("unit")]
    public async Task<JsonResult> GetUnit()
    {
        var result = await _repository.Op_26();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/unit
    [HttpPut]
    [Route("unit")]
    public async Task<JsonResult> AddUnit([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/unit
    [HttpDelete]
    [Route("unit")]
    public async Task<JsonResult> DeleteUnit([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/drafter
    [HttpGet]
    [Route("drafter")]
    public async Task<JsonResult> GetDrafter()
    {
        var result = await _repository.Op_29();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/drafter
    [HttpPut]
    [Route("drafter")]
    public async Task<JsonResult> AddDrafter([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/drafter
    [HttpDelete]
    [Route("drafter")]
    public async Task<JsonResult> DeleteDrafter([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/checker
    [HttpGet]
    [Route("checker")]
    public async Task<JsonResult> GetChecker()
    {
        var result = await _repository.Op_32();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/checker
    [HttpPut]
    [Route("checker")]
    public async Task<JsonResult> AddChecker([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_33(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/checker
    [HttpDelete]
    [Route("checker")]
    public async Task<JsonResult> DeleteChecker([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/dwms/customer
    [HttpGet]
    [Route("customer")]
    public async Task<JsonResult> GetCustomer()
    {
        var result = await _repository.Op_35();
        return BaseResult.JsonResult(result);
    }

    //PUT api/dwms/customer
    [HttpPut]
    [Route("customer")]
    public async Task<JsonResult> AddCustomer([FromBody] DWMSProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_36(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/dwms/customer
    [HttpDelete]
    [Route("customer")]
    public async Task<JsonResult> DeleteCustomer([FromBody] DWMSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_37(model);
        return BaseResult.JsonResult(result);
    }
}