using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models.File;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IBLOBServiceNew
{
    public Task<List<string>> Upload(HttpContext context, string module, Department department, bool alwaysUseProduction = false);

    Task<FileStreamResult> Download(FileDownloadRequest fileDownloadRequest);

    Task<bool> Delete(FileDeleteRequest fileDeleteRequest);

    Task<FileStreamResult> DownloadDirect(string containerName, string path);

    Task<FileStreamResult> DownloadLatest(string containerName, string? path = null);
}
