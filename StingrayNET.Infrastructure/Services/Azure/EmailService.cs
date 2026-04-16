using Microsoft.Extensions.Configuration;
using Microsoft.Graph;
using Microsoft.Graph.Users.Item.SendMail;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using System;
using System.Threading.Tasks;
using System.IO;
using Microsoft.AspNetCore.Mvc;
using System.Net.Mime;
using MsgKit;
using MsgKit.Enums;
using System.Linq;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Text;
using Microsoft.AspNetCore.Http;

namespace StingrayNET.Infrastructure.Services.Azure;

public class EmailService : IEmailService
{
    private readonly IConfiguration _config;
    private readonly IKVService _kvService;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public EmailService(IConfiguration config, IKVService kVService, IHttpContextAccessor httpContextAccessor)
    {
        _config = config;
        _kvService = kVService;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<bool> Send(EmailTemplate emailTemplate)
    {

        GraphServiceClient graphServiceClient = new GraphServiceClient(_kvService.GetCredential());

        var requestBody = new SendMailPostRequestBody
        {
            Message = new Microsoft.Graph.Models.Message
            {
                Subject = emailTemplate.Subject,
                Body = emailTemplate.EmailBody,

                ToRecipients = emailTemplate.ToList ?? new List<Microsoft.Graph.Models.Recipient>(),
                CcRecipients = emailTemplate.CCList ?? new List<Microsoft.Graph.Models.Recipient>(),
                BccRecipients = emailTemplate.BCCList ?? new List<Microsoft.Graph.Models.Recipient>(),
                Attachments = emailTemplate.Attachments ?? new List<Microsoft.Graph.Models.Attachment>(),
                Importance = emailTemplate.Importance
            }
        };

        await graphServiceClient.Users[_config["Email:Address"]].SendMail.PostAsync(requestBody);
        return true;


        //if()

        //return await RegisterinDB(emailTemplate);
    }
#nullable enable
    public async Task<bool> SendWithCheck(List<string> toList, string subject, string emailBody,
    EmailImportance emailImportance = EmailImportance.Normal, List<string>? CCList = null, List<string>? BCCList = null,
    string? fromAddress = null, List<Microsoft.Graph.Models.Attachment>? attachments = null, bool isTestEmail = false)
    {
        //check for empty to list
        if (!toList.Any())
        {
            return false;
        }

        //convert to hashsets to remove duplicates
        HashSet<string> uniqueTo = new HashSet<string>(toList);
        toList = new List<string>(uniqueTo);

        if (CCList != null)
        {
            HashSet<string> uniqueCC = new HashSet<string>(CCList);
            CCList = new List<string>(uniqueCC);
        }


        if (BCCList != null)
        {
            HashSet<string> uniqueBCC = new HashSet<string>(BCCList);
            BCCList = new List<string>(uniqueBCC);
        }

        //remove all empty strings if needed
        toList.RemoveAll(str => str.Equals(""));
        CCList?.RemoveAll(str => str.Equals(""));
        BCCList?.RemoveAll(str => str.Equals(""));
        toList.RemoveAll(str => str == null);
        CCList?.RemoveAll(str => str == null);
        BCCList?.RemoveAll(str => str == null);

        string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        bool isProd = (env == null) ? false : env.Equals("Production");

        List<string> recipients = new List<string>();

        if (!isProd || isTestEmail)
        {
            string disclaimerBody = "<p><b style='color:red'>DISCLAIMER: This email was sent for testing purposes, please disregard. This is NOT Production</b></p>";
            string impersonateBody = "";
            string username = ((ApplicationCore.Models.Admin.User)(_httpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"])).UserPrincipalName;
            if (_httpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS"))
            {
                impersonateBody = "<p><b style='color:red'>YOU ARE IMPERSONATING A USER: This test email would go to " + ((ApplicationCore.Models.Admin.User)(_httpContextAccessor.HttpContext.Items[@"STNGUser"])).UserPrincipalName + " if they weren't being impersonated.</b></p>";
            }

            emailBody = disclaimerBody + impersonateBody + "<p>To: " + string.Join(", ", toList) + "<br/>CC: " + string.Join(", ", CCList ?? new List<string>()) + "<br/>BCC: " + string.Join(", ", BCCList ?? new List<string>()) + "</p><p>" + emailBody + "</p>";
            subject = "TESTING: " + subject;

            CCList?.Clear();
            BCCList?.Clear();
            toList.Clear();
            if (username != null)
            {
                toList.Add(username);
            }
        }

        emailBody += "<div style=\"text-align: center;\"><i>Powered by DMS/Stingray | A Bruce Power Modern Open Platform Web Solution<br>Interested in building a module? <a href=\"https://bpinfonet.sharepoint.com/sites/SupplyChain/Stingray/Pages/default.aspx\">Click to learn more</a></i></div>";


        return await Send(new EmailTemplate(toList, subject, emailBody, emailImportance: emailImportance, CCList: CCList, BCCList: BCCList, fromAddress: fromAddress, attachments: attachments));

    }

#nullable disable

    public async Task<FileStreamResult> Download(MsgTemplate template, string filename)
    {

        using (var email = new Email(new Sender(template.FromAddress, ""), template.Subject, true))
        {
            template.ToAddress.ForEach(address => { email.Recipients.AddTo(address); });
            template.CCAddress?.ForEach(address => { email.Recipients.AddCc(address); });
            template.BccAddress?.ForEach(address => { email.Recipients.AddBcc(address); });
            email.BodyHtml = template.HtmlBody;
            email.Importance = MessageImportance.IMPORTANCE_NORMAL;
            email.IconIndex = MessageIconIndex.ReadMail;

            MemoryStream stream = new MemoryStream();
            email.Save(stream);

            stream.Seek(0, SeekOrigin.Begin);
            string media = MediaTypeNames.Application.Octet;
            return new FileStreamResult(stream, media)
            {
                FileDownloadName = $"{filename}.msg"
            };
        }



    }


    public async Task<string> Inject(string originalHTML, Dictionary<string, string> injections)
    {
        //Assumes all placeholders in originalHTML are qualified with <!--x--> with x being the key in injections dict
        string workingHTML = originalHTML;
        MatchCollection matches = Regex.Matches(originalHTML, @"\<\!\-\-([^\-]+)\-\-\>");
        foreach (Match placeholder in matches)
        {
            //Get key
            string injectionKey = Regex.Match(placeholder.Value, @"(?<=\<\!\-\-)([^\-]+)(?=\-\-\>)").Value;

            //Get injection
            if (injections.ContainsKey(injectionKey))
            {
                string injection = injections[injectionKey];

                //Inject
                workingHTML = Regex.Replace(workingHTML, string.Format(@"\<\!\-\-({0})\-\-\>", injectionKey), injection);
            }

        }

        return workingHTML;
    }

    //Will produce a HTML table with columns in the order of the keys in the Dictionary<string,object> entries (Left to right)
    public async Task<string> ToHTMLTable(List<object> data)
    {
        StringBuilder sb = new StringBuilder();
        if (data.Count == 0)
        {
            return string.Empty;
        }

        //Start table
        sb.Append(@"<table>");

        //Do header
        sb.Append(@"<thead><tr>");
        Dictionary<string, object> firstRow = (Dictionary<string, object>)data[0];
        foreach (string key in firstRow.Keys)
        {
            sb.Append(string.Format(@"<th>{0}</th>", key));
        }
        sb.Append(@"</tr></thead>");

        //Do body
        sb.Append(@"<tbody>");
        foreach (var row in data)
        {
            //Cast
            Dictionary<string, object> rowDict = (Dictionary<string, object>)row;

            sb.Append(@"<tr>");

            foreach (string col in rowDict.Keys)
            {
                sb.Append(string.Format(@"<td>{0}</td>", rowDict[col] == null ? string.Empty : rowDict[col].ToString()));
            }

            sb.Append(@"</tr>");
        }

        sb.Append(@"</tbody>");

        //End table and return
        sb.Append(@"</table>");
        return sb.ToString();

        /*
        <table class="tg">
        <thead>
        <tr>
            <th class="tg-bold"></th>
            <th class="tg-bold" colspan="3">DMS Status</th>
            <th class="tg-bold">Actions to be Taken</th>
            <th class="tg-bold">Compliance Stats</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td class="tg-bold">Sections/<br>Departments</td>
            <td class="tg-bold">Awaiting Assessment/<br>Awaiting SM Assessment</td>
            <td class="tg-bold"width=100px>Execution</td>
            <td class="tg-bold" width=100px>Total</td>
            <td class="tg-bold">Set Missing TCDs/<br>TCDs Past Due</td>
            <td class="tg-bold">Average Age of ERs Missing TCDs<br>(<span style="color:green">Green</span> < 10 days)</td>
        </tr>
        <[TableBody]>
        </tbody>
        </table>
        */
    }

    //TODO: Address this as an addtional method in the implementation
    //private async Task<string> RegisterinDB(EmailTemplate emailTemplate) 
    //{
    //    //Convert EmailTemplate into DBParams
    //    List<DBParam> dBParams = new List<DBParam>();

    //    //Add operation
    //    dBParams.Add(new DBParam(parameterName: @"@Operation",));

    //    foreach(FieldInfo fld in emailTemplate.GetType().GetFields()) 
    //    {
    //        dBParams.Add(
    //            new DBParam(
    //                parameterName: String.Format(@"@{0}",fld.Name), 
    //                value: fld.GetValue(emailTemplate), 
    //                dataType: _generalUtils.ConvertToSQLDBType(fld.FieldType))
    //                ));

    //    }

    //    DBRequest request = new DBRequest(queryText: _config["Email:StoredProcedure"], DBParams: dBParams);

    //    return await _databaseService.Write(request);

    //}

}
