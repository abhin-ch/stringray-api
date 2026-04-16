using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Plugin;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
public class PluginController : BaseApiController
{
    private readonly IRepositoryS<PluginProcedure, PluginResult> _repository;
    private readonly IBLOBServiceNew _blobService;
    public PluginController(IIdentityService identityService, IRepositoryS<PluginProcedure, PluginResult> repository, IBLOBServiceNew blobService) : base(identityService)
    {
        _repository = repository;
        _blobService = blobService;
    }

    //GET plugin
    //Download Plugin
    [HttpGet]
    public async Task<FileStreamResult> GetPlugin()
    {
        return await _blobService.DownloadLatest(@"utilities", @"STNGPlugin");
    }

    //GET plugin/installer
    //Download Plugin Installer
    [HttpGet]
    [Route(@"installer")]
    public async Task<FileStreamResult> GetPluginInstaller()
    {
        return await _blobService.DownloadLatest(@"utilities", @"STNGPluginInstaller");
        //return await _blobService.DownloadDirect(@"utilities", @"STNGPluginInstaller/Local");
    }

    //PUT plugin/session
    //Create Plugin Session
    //Requires SessionTemplate; SessionTaskParameters are optional
    [HttpPut]
    [Route("session")]
    public async Task<JsonResult> GetSessionToken(PluginProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_03(model));
    }

    //POST plugin/session/status
    //Poll Session status
    //Requires SessionID
    [HttpPost]
    [Route("session/status")]
    public async Task<JsonResult> PollSessionStatus(PluginProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_02(model));
    }

    //POST plugin/session/task
    //Get Session tasks
    //Requires SessionID
    [HttpPost]
    [Route("session/task")]
    public async Task<JsonResult> GetSessionTasks(PluginProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_04(model));
    }

    //POST plugin/session/task/subtask
    //Get Session subtasks
    //Requires SessionID and SessionTaskID
    [HttpPost]
    [Route("session/task/subtask")]
    public async Task<JsonResult> GetSessionSubTasks(PluginProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_06(model));
    }

    //PATCH plugin/session/task/status
    //Alter Session task status
    //Requires InstanceID, SessionStatus
    [HttpPatch]
    [Route("session/task/status")]
    public async Task<JsonResult> AlterSessionTaskStatus(PluginProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_05(model));
    }

    //PATCH plugin/session/status
    //Alter Session status (Status of all tasks)
    //Requires SessionID, SessionStatus
    [HttpPatch]
    [Route("session/status")]
    public async Task<JsonResult> AlterSessionStatus(PluginProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_07(model));
    }

    //GET plugin/installer/manifest
    //Get Installer Manifest
    [HttpGet]
    [Route(@"installer/manifest")]
    public async Task<JsonResult> GetInstallerManifest()
    {
        return BaseResult.JsonResult(await _repository.Op_01());
    }

    //GET plugin/version
    //Get Latest Plugin Information
    [HttpGet]
    [Route(@"version")]
    public async Task<JsonResult> GetLatestVersion()
    {
        var result = await _repository.Op_08();

        return BaseResult.JsonResult(await _repository.Op_08());
    }

}
