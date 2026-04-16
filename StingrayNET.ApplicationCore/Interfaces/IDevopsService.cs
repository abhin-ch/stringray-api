using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.IO;
using StingrayNET.ApplicationCore.Models.Common.DevOps;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IDevopsService
{
    public Task<ActionResult<string>> SendAddWIRequest(AddWIRequest AddWIRequest, HttpContext context);

    public Task<ActionResult<string>> AddAttachment(AddAttachmentRequest AddAttachmentRequest, Stream stream);

    public Task<bool> LinkAttachment(LinkAttachmentRequest linkAttachmentRequest);
}

