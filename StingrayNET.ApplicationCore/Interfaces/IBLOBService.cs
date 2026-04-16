using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.File;
using System;
using System.IO;
using System.Threading.Tasks;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IBLOBService
{
    Task<string> StartUpload(FileStartRequest fileStartRequest);

    Task UploadChunk(FileChunkRequest fileChunkRequest, Stream body);

    Task EndUpload(FileEndRequest fileEndRequest);

    Task<FileStreamResult> Download(FileDownloadRequest fileDownloadRequest);

    Task<bool> Delete(FileDeleteRequest fileDeleteRequest);
}
