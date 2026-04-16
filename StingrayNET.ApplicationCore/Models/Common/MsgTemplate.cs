using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.Common;

public class MsgTemplate 
{
    public string? FromAddress {get;set;}
    public List<string>? ToAddress {get;set;}
    public List<string>? CCAddress {get;set;}
    public List<string>? BccAddress {get;set;}
    public string? HtmlBody {get;set;}
    public string? Subject {get;set;}

    public MsgTemplate(){}

    public MsgTemplate(string fromAddress, List<string> toAddress, string htmlBody, string subject, List<string>? ccAddress = null, List<string>? bccAddress = null)
    {
        FromAddress = fromAddress;
        ToAddress = toAddress;
        HtmlBody = htmlBody;
        Subject = subject;
        CCAddress = ccAddress;
        BccAddress = bccAddress;
    }
}