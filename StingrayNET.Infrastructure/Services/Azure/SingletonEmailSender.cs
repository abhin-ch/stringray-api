
using Microsoft.Graph.Users.Item.SendMail;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.Models.Common;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using StingrayNET.ApplicationCore.Models.Admin;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using System;
using Microsoft.Extensions.DependencyInjection;
using StingrayNET.ApplicationCore.Interfaces;

namespace StingrayNET.Infrastructure.Services.Azure;

public interface ISingletonEmailSender
{
    public Task<bool> Send(GraphServiceClient graphServiceClient, EmailTemplate emailTemplate);
    public Task<bool> SendWithCheck(User originalUser, bool impersonating, QuickEmailTemplate emailTemplate, bool isTestEmail = false);

    public bool IsValidEmail(string email);
}

public class SingletonEmailSender : ISingletonEmailSender
{
    private readonly IConfiguration _config;
    private readonly IServiceScopeFactory _serviceScopeFactory;

    public SingletonEmailSender(IConfiguration config, IServiceScopeFactory serviceScopeFactory)
    {
        _config = config;
        _serviceScopeFactory = serviceScopeFactory;
    }

    /// <summary>
    /// Sends email with a check. Check will send email to user if in DEV or QA. Will also add additional text if impersonating. Will also add DMS 2.0 footer to every email.
    /// </summary>
    /// <param name="graphServiceClient">Needs to be passed 'new GraphServiceClient(_kvService.GetCredential())', have not tested capability of creating scope here to eliminate this param</param>
    /// <param name="originalUser">Needs to be passed HttpContextAccessor.HttpContext.Items[@"OriginalSTNGUser"], as there is a risk of httpContext expiry with singleton usage</param>
    /// <param name="impersonating">Needs to be passed HttpContextAccessor.HttpContext.Request.Headers.ContainsKey(@"STNG-IMPERSONATE-AS"),  as there is a risk of httpContext expiry with singleton usage</param>
    /// <param name="isTestEmail">Optional boolean if wanting to send a test email, will always only send to user if true</param>
    /// <returns></returns>
    public async Task<bool> SendWithCheck(User originalUser, bool impersonating,
    QuickEmailTemplate emailTemplate, bool isTestEmail = false)
    {
        //scoped services need new scope created, since this is being used in singleton (after original scope closure)
        using var scope = _serviceScopeFactory.CreateScope();
        var _kvService = scope.ServiceProvider.GetRequiredService<IKVService>();

        GraphServiceClient graphServiceClient = new GraphServiceClient(_kvService.GetCredential());

        //check for empty to list
        if (!emailTemplate.toList.Any())
        {
            return false;
        }

        //convert to hashsets to remove duplicates
        HashSet<string> uniqueTo = new HashSet<string>(emailTemplate.toList);
        emailTemplate.toList = new List<string>(uniqueTo);

        if (emailTemplate.CCList != null)
        {
            HashSet<string> uniqueCC = new HashSet<string>(emailTemplate.CCList);
            emailTemplate.CCList = new List<string>(uniqueCC);
        }


        if (emailTemplate.BCCList != null)
        {
            HashSet<string> uniqueBCC = new HashSet<string>(emailTemplate.BCCList);
            emailTemplate.BCCList = new List<string>(uniqueBCC);
        }

        //remove all invalid emails
        emailTemplate.toList.RemoveAll(str => !IsValidEmail(str));
        emailTemplate.CCList?.RemoveAll(str => !IsValidEmail(str));
        emailTemplate.BCCList?.RemoveAll(str => !IsValidEmail(str));

        string? env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT");
        bool isProd = (env == null) ? false : env.Equals("Production");

        List<string> recipients = new List<string>();

        if (!isProd || isTestEmail)
        {
            string disclaimerBody = "<p><b style='color:red'>DISCLAIMER: This email was sent for testing purposes, please disregard. This is NOT Production</b></p>";
            string impersonateBody = "";
            string username = originalUser.UserPrincipalName;
            if (impersonating)
            {
                impersonateBody = "<p><b style='color:red'>YOU ARE IMPERSONATING A USER: This test email would go to " + originalUser.UserPrincipalName + " if they weren't being impersonated.</b></p>";
            }

            emailTemplate.emailBody = disclaimerBody + impersonateBody + "<p>To: " + string.Join(", ", emailTemplate.toList) + "<br/>CC: " + string.Join(", ", emailTemplate.CCList ?? new List<string>()) + "<br/>BCC: " + string.Join(", ", emailTemplate.BCCList ?? new List<string>()) + "</p><p>" + emailTemplate.emailBody + "</p>";
            emailTemplate.subject = "TESTING: " + emailTemplate.subject;

            emailTemplate.CCList?.Clear();
            emailTemplate.BCCList?.Clear();
            emailTemplate.toList.Clear();
            if (username != null)
            {
                emailTemplate.toList.Add(username);
            }
        }

        emailTemplate.emailBody += "<div style=\"text-align: center;\"><i>Powered by DMS/Stingray | A Bruce Power Modern Open Platform Web Solution<br>Interested in building a module? <a href=\"https://bpinfonet.sharepoint.com/sites/SupplyChain/Stingray/Pages/default.aspx\">Click to learn more</a></i></div>";


        return await Send(graphServiceClient, new EmailTemplate(emailTemplate.toList, emailTemplate.subject, emailTemplate.emailBody, emailImportance: emailTemplate.emailImportance, CCList: emailTemplate.CCList, BCCList: emailTemplate.BCCList, fromAddress: emailTemplate.fromAddress, attachments: emailTemplate.attachments));

    }

    public async Task<bool> Send(GraphServiceClient graphServiceClient, EmailTemplate emailTemplate)
    {

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
    }

    public bool IsValidEmail(string email)
    {
        try
        {
            return new System.Net.Mail.MailAddress(email).Address == email;
        }
        catch
        {
            return false;
        }
    }
}