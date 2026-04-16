
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models.Common;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Interfaces;
//TODO: Include a delegate for reaction actions?
public interface IEmailService
{
    Task<bool> Send(EmailTemplate template);
    Task<bool> SendWithCheck(List<string> toList, string subject, string emailBody, EmailImportance emailImportance = EmailImportance.Normal
    , List<string>? CCList = null, List<string>? BCCList = null, string? fromAddress = null
    , List<Microsoft.Graph.Models.Attachment>? attachments = null, bool isTestEmail = false);
    Task<FileStreamResult> Download(MsgTemplate template, string filename);

    Task<string> Inject(string originalHTML, Dictionary<string, string> injections);
    Task<string> ToHTMLTable(List<object> data);
}
