using Microsoft.Graph;
using Microsoft.Graph.Models;
using System.Collections.Generic;

#nullable disable

namespace StingrayNET.ApplicationCore.Models.Common;

public enum EmailImportance
{
    High = 1,
    Normal = 2,
    Low = 3
}

public class EmailTemplate
{
    public readonly Recipient From;
    public readonly List<Recipient> ToList;
    public readonly List<Recipient> CCList;
    public readonly List<Recipient> BCCList;

    public readonly List<Attachment> Attachments;

    public readonly string Subject;
    public readonly Importance Importance;
    public readonly ItemBody EmailBody;

#nullable enable
    public EmailTemplate(List<string> toList, string subject, string emailBody, EmailImportance emailImportance = EmailImportance.Normal, List<string>? CCList = null, List<string>? BCCList = null, string? fromAddress = null, List<Attachment>? attachments = null)
    {
        ToList = ConvertToRecipient(toList);
        this.CCList = ConvertToRecipient(CCList);
        this.BCCList = ConvertToRecipient(BCCList);
        From = new Recipient { EmailAddress = new EmailAddress { Address = fromAddress } };

        Subject = subject;
        Importance = ConvertImportance(emailImportance);
        EmailBody = new ItemBody { ContentType = BodyType.Html, Content = emailBody };
        Attachments = attachments;
    }

    public EmailTemplate(List<Recipient> toList, string subject, string emailBody, EmailImportance emailImportance = EmailImportance.Normal, List<Recipient>? CCList = null, List<Recipient>? BCCList = null, string? fromAddress = null, List<Attachment>? attachments = null)
    {
        ToList = toList;
        this.CCList = CCList;
        this.BCCList = BCCList;
        From = new Recipient { EmailAddress = new EmailAddress { Address = fromAddress } };

        Subject = subject;
        Importance = ConvertImportance(emailImportance);
        EmailBody = new ItemBody { ContentType = BodyType.Html, Content = emailBody };
        Attachments = attachments;
    }

    private static List<Recipient>? ConvertToRecipient(List<string>? inputList)
    {
        if (inputList == null)
        {
            return null;
        }

        List<Recipient> recipients = new List<Recipient>();

        foreach (string input in inputList)
        {
            recipients.Add(new Recipient { EmailAddress = new EmailAddress { Address = input } });
        }

        return recipients;

    }
#nullable disable
    private Importance ConvertImportance(EmailImportance emailImportance)
    {
        switch (emailImportance)
        {
            case EmailImportance.Low:
                {
                    return Importance.Low;
                }

            case EmailImportance.Normal:
                {
                    return Importance.Normal;
                }

            case EmailImportance.High:
                {
                    return Importance.High;
                }

            default:
                {
                    return Importance.Normal;
                }

        }
    }

}

#nullable enable


public class QuickEmailTemplate
{
    public List<string> toList;
    public string subject;
    public string emailBody;
    public EmailImportance emailImportance = EmailImportance.Normal;
    public List<string>? CCList = null;
    public List<string>? BCCList = null;
    public string? fromAddress = null;
    public List<Microsoft.Graph.Models.Attachment>? attachments = null;

}
