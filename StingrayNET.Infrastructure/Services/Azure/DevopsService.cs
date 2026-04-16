using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using System.Threading.Tasks;
using System;
using System.IO;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using Microsoft.VisualStudio.Services.WebApi.Patch.Json;
using Microsoft.VisualStudio.Services.WebApi.Patch;
using Microsoft.TeamFoundation.WorkItemTracking.WebApi.Models;
using Microsoft.VisualStudio.Services.WebApi;
using Microsoft.TeamFoundation.WorkItemTracking.WebApi;
using Azure.Core;
using Microsoft.VisualStudio.Services.Client;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.Common.DevOps;

namespace StingrayNET.Infrastructure.Services.Azure;

public class DevopsService : IDevopsService
{
    private readonly IKVService _kvService;
    private readonly IConfiguration _config;
    private readonly IIdentityService _identityService;

    public DevopsService(IKVService kvService, IConfiguration config, IIdentityService identityService)
    {
        _kvService = kvService;
        _config = config;
        _identityService = identityService;
    }

    private async Task<WorkItemTrackingHttpClient> GetClient()
    {
        //Get URI
        Uri requestURI = new Uri(_config["DevOps:OrgURL"]);

        //Setup VSSConnection
        string accessToken = (await _kvService.GetCredential().GetTokenAsync(new TokenRequestContext(new string[] { _config["DevOps:DefaultScope"] }))).Token;
        VssAadToken vssToken = new VssAadToken(@"Bearer", accessToken);

        VssAadCredential cred = new VssAadCredential(vssToken);

        VssConnection conn = new VssConnection(requestURI, cred);

        //Return
        return conn.GetClient<WorkItemTrackingHttpClient>();
    }

    public async Task<ActionResult<string>> SendAddWIRequest(AddWIRequest AddWIRequest, HttpContext context)
    {
        try
        {
            //Get Project
            string project = _config["DevOps:Project"];

            //Add request body
            List<AddWISubrequest> subRequests = AddWIRequest.AddWISubrequests;

            //Add to working patchdocument
            JsonPatchDocument patchDocument = new JsonPatchDocument();
            foreach (AddWISubrequest sub in subRequests)
            {
                if (sub.path.Contains(@"System.Title"))
                {

                    patchDocument.Add(new JsonPatchOperation()
                    {
                        Operation = Operation.Add,
                        Path = sub.path,
                        Value = string.Format(@"{0} ({1})", sub.value, Guid.NewGuid())
                    });

                }

                else
                {
                    patchDocument.Add(new JsonPatchOperation()
                    {
                        Operation = Operation.Add,
                        Path = sub.path,
                        Value = sub.value
                    });
                }

            }

            //Add Requester
            string requester = (await _identityService.GetUser(context)).Email;

            patchDocument.Add(new JsonPatchOperation()
            {
                Operation = Operation.Add,
                Path = @"/fields/Custom.Requester",
                Value = requester
            });

            //Get client
            WorkItemTrackingHttpClient client = await GetClient();

            //Send request
            var result = await client.CreateWorkItemAsync(patchDocument, project, AddWIRequest.WIType);

            //Return to client
            return new OkObjectResult(result.Id);

        }

        catch (Exception e)
        {
            return new BadRequestObjectResult(string.Format(@"Error occurred during WI Addition API call - {0}", e.Message));
        }

    }

    public async Task<ActionResult<string>> AddAttachment(AddAttachmentRequest addAttachmentRequest, Stream stream)
    {

        WorkItemTrackingHttpClient client = await GetClient();

        AttachmentReference response = await client.CreateAttachmentAsync(uploadStream: stream, fileName: addAttachmentRequest.FileName);

        return new OkObjectResult(response.Url);

    }

    public async Task<bool> LinkAttachment(LinkAttachmentRequest linkAttachmentRequest)
    {
        WorkItemTrackingHttpClient client = await GetClient();

        foreach (DevOpsAttachment attachment in linkAttachmentRequest.Attachments)
        {
            JsonPatchDocument doc = new JsonPatchDocument()
                {
                    new JsonPatchOperation()
                    {
                        Operation = Operation.Add,
                        Path = @"/relations/-",
                        Value = new
                        {
                            rel="AttachedFile",
                            url = attachment.URL,
                            attributes = new {comment = attachment.FileName}
                        }
                    }
                };

            await client.UpdateWorkItemAsync(doc, linkAttachmentRequest.WI);

        }

        return true;
    }

}

