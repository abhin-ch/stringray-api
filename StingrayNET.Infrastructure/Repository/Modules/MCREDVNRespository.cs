using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.MCREDVN;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models.File;
using Microsoft.Graph.Models;
using System.IO;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class MCREDVNRepository : BaseRepository<MCREDVNResult>, IRepositoryL<MCREDVNProcedure, MCREDVNResult>
{
    private readonly IBLOBService _blobService;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IEmailService _emailService;

    public MCREDVNRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor, IEmailService emailService, IBLOBService blobService) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
        _emailService = emailService;
        _blobService = blobService;
    }

    protected override string Query => "stng.SP_MCRE_DVN_CRUD";

    public async Task<MCREDVNResult> Op_01(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(1, model);
    }

    public async Task<MCREDVNResult> Op_02(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<MCREDVNResult> Op_03(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<MCREDVNResult> Op_04(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(4);
    }

    public async Task<MCREDVNResult> Op_05(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var origResult = await ExecuteReader<DED>(5, model);

        return origResult;
    }

    public async Task<MCREDVNResult> Op_06(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<MCREDVNResult> Op_07(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<MCREDVNResult> Op_08(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<MCREDVNResult> Op_09(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<MCREDVNResult> Op_10(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<MCREDVNResult> Op_11(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var origResult = await ExecuteReader<DED>(11, model);

        var newResult = origResult;

        var getName = await ExecuteReader<DED>(99, model);
        var getCommentsName = getName;

        if (newResult.Data3 != null)
        {
            List<string> emailTo = new List<string>();
            string listToItem = DataParser.GetValueFromData<string>(newResult.Data1, @"ToEmail");
            emailTo.Add(listToItem);

            List<string> emailCC = new List<string>();
            string[] listCCItem = DataParser.GetValueFromData<string>(newResult.Data1, @"CCEmail").Split(';');
            foreach (var item in listCCItem)
            {
                emailCC.Add(item);
            }

            string projectNum = "P" + DataParser.GetValueFromData<string>(newResult.Data3, @"Project ID");
            string userName = DataParser.GetValueFromData<string>(newResult.Data1, @"FirstName");
            string comments = model.Comments;
            string commentsName = DataParser.GetValueFromData<string>(getCommentsName.Data1, @"Name");

            string emailBody = DataParser.GetValueFromData<string>(newResult.Data2, @"Body");
            string emailSubject = DataParser.GetValueFromData<string>(newResult.Data2, @"Subject");


            if (newResult.Data1.Count > 0)
            {
                string emailBodyTable1 = await _emailService.ToHTMLTable(newResult.Data3);
                string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>()
                    { { @"DVNItemTable", emailBodyTable1 },
                    { @"DVNUserName", userName },
                    { @"DVNComments", comments },
                    { @"DVNCommentsName", commentsName } });

                string emailSubject2 = await _emailService.Inject(emailSubject, new Dictionary<string, string>() { { @"DVNProjectNum", projectNum } });

                EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject2, emailBody: emailBody2, CCList: emailCC);
                await _emailService.Send(template);
            }
        }

        return origResult;
    }

    public async Task<MCREDVNResult> Op_12(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<MCREDVNResult> Op_13(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<MCREDVNResult> Op_14(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<MCREDVNResult> Op_15(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }
    public async Task<MCREDVNResult> Op_16(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<MCREDVNResult> Op_17(MCREDVNProcedure model = null)
    {
        //return await ExecuteReader<DED>(17, model, throwException: true);

        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var origResult = await ExecuteReader<DED>(17, model);

        var newResult = await ExecuteReader<DED>(97, model);
        var newResultData = newResult;

        var getName = await ExecuteReader<DED>(99, model);
        var getUserName = getName;

        if (newResultData.Data1.Count > 0)
        {
            var finalResult = await ExecuteReader<DED>(96, model);
            var finalResultData = finalResult;

            List<string> emailTo = new List<string>();
            string listToItem = DataParser.GetValueFromData<string>(finalResultData.Data1, @"ToEmail");
            emailTo.Add(listToItem);

            List<string> emailCC = new List<string>();
            string[] listCCItem = DataParser.GetValueFromData<string>(finalResultData.Data1, @"CCEmail").Split(';');
            foreach (var item in listCCItem)
            {
                emailCC.Add(item);
            }

            string projectNum = "P" + DataParser.GetValueFromData<string>(finalResultData.Data3, @"Project ID");
            string userName = DataParser.GetValueFromData<string>(finalResultData.Data1, @"FirstName");
            string comments = "You have been assigned as delegate to approve this DVN.";
            string commentsName = DataParser.GetValueFromData<string>(getUserName.Data1, @"Name");

            string emailBody = DataParser.GetValueFromData<string>(finalResultData.Data2, @"Body");
            string emailSubject = DataParser.GetValueFromData<string>(finalResultData.Data2, @"Subject");


            if (finalResultData.Data1.Count > 0)
            {
                string emailBodyTable1 = await _emailService.ToHTMLTable(finalResultData.Data3);
                string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>()
                    { { @"DVNItemTable", emailBodyTable1 },
                     { @"DVNUserName", userName },
                     { @"DVNComments", comments },
                    { @"DVNCommentsName", commentsName }  });

                string emailSubject2 = await _emailService.Inject(emailSubject, new Dictionary<string, string>() { { @"DVNProjectNum", projectNum } });

                EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject2, emailBody: emailBody2, CCList: emailCC);
                await _emailService.Send(template);
            }
        }
        return origResult;
    }

    public async Task<MCREDVNResult> Op_18(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }
    public async Task<MCREDVNResult> Op_19(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<MCREDVNResult> Op_20(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var origResult = await ExecuteReader<DED>(20, model);

        var newResult = origResult;

        var getName = await ExecuteReader<DED>(99, model);
        var getCommentsName = getName;

        if (newResult.Data2 != null && newResult.Data3 != null)
        {

            List<string> emailTo = new List<string>();
            string listToItem = DataParser.GetValueFromData<string>(newResult.Data1, @"ToEmail");
            emailTo.Add(listToItem);

            List<string> emailCC = new List<string>();
            string[] listCCItem = DataParser.GetValueFromData<string>(newResult.Data1, @"CCEmail").Split(';');
            foreach (var item in listCCItem)
            {
                emailCC.Add(item);
            }

            string projectNum = "P" + DataParser.GetValueFromData<string>(newResult.Data3, @"Project ID");
            string userName = DataParser.GetValueFromData<string>(newResult.Data1, @"FirstName");
            string comments = model.Comments;
            string commentsName = DataParser.GetValueFromData<string>(getCommentsName.Data1, @"Name");

            string emailBody = DataParser.GetValueFromData<string>(newResult.Data2, @"Body");
            string emailSubject = DataParser.GetValueFromData<string>(newResult.Data2, @"Subject");


            if (newResult.Data1.Count > 0)
            {
                string emailBodyTable1 = await _emailService.ToHTMLTable(newResult.Data3);
                string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>()
                    { { @"DVNItemTable", emailBodyTable1 },
                    { @"DVNUserName", userName },
                    { @"DVNComments", comments },
                    { @"DVNCommentsName", commentsName } });
                string emailSubject2 = await _emailService.Inject(emailSubject, new Dictionary<string, string>() { { @"DVNProjectNum", projectNum } });

                EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject2, emailBody: emailBody2, CCList: emailCC);
                await _emailService.Send(template);
            }
        }

        return origResult;
    }

    public async Task<MCREDVNResult> Op_21(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        var origResult = await ExecuteReader<DED>(21, model);
        var newResult = origResult;

        var additionalResult = await ExecuteReader<DED>(25, model);
        var detailResult = additionalResult;

        var getName = await ExecuteReader<DED>(99, model);
        var getCommentsName = getName;

        var getFiles = await ExecuteReader<DED>(98, model);
        var getFileNames = getFiles;

        if (model.Status == "Awaiting DM Approval")
        {
            List<string> emailTo = new List<string>();
            string listToItem = DataParser.GetValueFromData<string>(newResult.Data1, @"ToEmail");
            emailTo.Add(listToItem);

            List<string> emailCC = new List<string>();
            string[] listCCItem = DataParser.GetValueFromData<string>(newResult.Data1, @"CCEmail").Split(';');
            foreach (var item in listCCItem)
            {
                emailCC.Add(item);
            }

            //Header Portion of email
            string projectNum = "P" + DataParser.GetValueFromData<string>(newResult.Data3, @"Project ID");
            string unitNum = DataParser.GetValueFromData<string>(newResult.Data3, @"Unit");
            string projectTitle = DataParser.GetValueFromData<string>(newResult.Data3, @"Project Name");
            string mcrProgram = DataParser.GetValueFromData<string>(newResult.Data3, @"MCR Program");
            string dvnCause = DataParser.GetValueFromData<string>(newResult.Data3, @"DVNCause");
            string pcsName = DataParser.GetValueFromData<string>(newResult.Data1, @"PCSName");
            string oeName = DataParser.GetValueFromData<string>(newResult.Data1, @"OEName");
            string pmName = DataParser.GetValueFromData<string>(newResult.Data1, @"PMName");

            string emailBody = DataParser.GetValueFromData<string>(newResult.Data2, @"Body");
            string emailSubject = DataParser.GetValueFromData<string>(newResult.Data2, @"Subject");

            //Signatures
            string oeSign = DataParser.GetValueFromData<string>(detailResult.Data3, @"OEsignature");
            string pmSign = DataParser.GetValueFromData<string>(detailResult.Data3, @"PMsignature");
            string smSign = DataParser.GetValueFromData<string>(detailResult.Data3, @"SMsignature");
            string dmSign = DataParser.GetValueFromData<string>(detailResult.Data3, @"DMsignature");

            if (newResult.Data1.Count > 0)
            {
                string emailBodyTable1 = await _emailService.ToHTMLTable(detailResult.Data1);
                string emailBodyTable2 = await _emailService.ToHTMLTable(detailResult.Data2);
                string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>()
                    { { @"DVNActivityTable", emailBodyTable1 },
                    { @"DVNMROCTable", emailBodyTable2 },
                    { @"DVNUnit", unitNum },
                    { @"DVNProject", projectNum },
                    { @"DVNTitle", projectTitle },
                    { @"DVNProgram", mcrProgram },
                    { @"DVNCause", dvnCause },
                    { @"DVNPCS", pcsName },
                    { @"DVNOE", oeName },
                    { @"DVNPM", pmName },
                    { @"DVNOESSign", oeSign},
                    { @"DVNSMSign", smSign},
                    { @"DVNPMSign", pmSign},
                    { @"DVNDMSign", dmSign} });

                string emailSubject2 = await _emailService.Inject(emailSubject, new Dictionary<string, string>() { { @"DVNProjectNum", projectNum } });

                List<Attachment> attachments1 = new List<Attachment>();

                List<string> items = DataParser.GetListFromData(getFileNames.Data1, @"UUID");

                foreach (var item in items)
                {
                    FileDownloadRequest fileRequest = new FileDownloadRequest();
                    fileRequest.UUID = item.ToString();

                    FileStreamResult fileAttachment = await _blobService.Download(fileRequest);

                    FileAttachment attach = new FileAttachment();
                    attach.Name = fileAttachment.FileDownloadName;
                    attach.ContentType = fileAttachment.ContentType;
                    attach.OdataType = "#microsoft.graph.fileAttachment";

                    using (MemoryStream memoryStream = new MemoryStream())
                    {
                        await fileAttachment.FileStream.CopyToAsync(memoryStream);

                        attach.ContentBytes = memoryStream.ToArray();
                    }


                    attachments1.Add(attach);

                }

                EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject2, emailBody: emailBody2, CCList: emailCC, attachments: attachments1);
                await _emailService.Send(template);
            }
        }
        else if (newResult.Data2 != null && newResult.Data3 != null)
        {
            List<string> emailTo = new List<string>();
            string listToItem = DataParser.GetValueFromData<string>(newResult.Data1, @"ToEmail");
            emailTo.Add(listToItem);

            List<string> emailCC = new List<string>();
            string[] listCCItem = DataParser.GetValueFromData<string>(newResult.Data1, @"CCEmail").Split(';');
            foreach (var item in listCCItem)
            {
                emailCC.Add(item);
            }

            string projectNum = "P" + DataParser.GetValueFromData<string>(newResult.Data3, @"Project ID");
            string userName = DataParser.GetValueFromData<string>(newResult.Data1, @"FirstName");
            string comments = model.Comments;
            string commentsName = DataParser.GetValueFromData<string>(getCommentsName.Data1, @"Name");

            string emailBody = DataParser.GetValueFromData<string>(newResult.Data2, @"Body");
            string emailSubject = DataParser.GetValueFromData<string>(newResult.Data2, @"Subject");


            if (newResult.Data1.Count > 0)
            {
                string emailBodyTable1 = await _emailService.ToHTMLTable(newResult.Data3);
                string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>()
                    { { @"DVNItemTable", emailBodyTable1 },
                     { @"DVNUserName", userName },
                     { @"DVNComments", comments },
                    { @"DVNCommentsName", commentsName }  });

                string emailSubject2 = await _emailService.Inject(emailSubject, new Dictionary<string, string>() { { @"DVNProjectNum", projectNum } });

                EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject2, emailBody: emailBody2, CCList: emailCC);
                await _emailService.Send(template);
            }
        }

        return origResult;
    }
    public async Task<MCREDVNResult> Op_22(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<MCREDVNResult> Op_23(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<MCREDVNResult> Op_24(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(24, model);
    }
    public async Task<MCREDVNResult> Op_25(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<MCREDVNResult> Op_26(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<MCREDVNResult> Op_27(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }
    public async Task<MCREDVNResult> Op_28(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<MCREDVNResult> Op_29(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public async Task<MCREDVNResult> Op_30(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(30, model);
    }
    public async Task<MCREDVNResult> Op_31(MCREDVNProcedure model = null)
    {
        //model.CurrentUser = (await _identityService.GetEmployeeID(_httpContextAccessor.HttpContext)).ToString();
        var origResult = await ExecuteReader<DED>(31, model);

        var newResult = origResult;

        if (newResult.Data1 != null)
        {
            foreach (object obj in newResult.Data1)
            {
                var temp = (Dictionary<string, object>)obj;
                List<string> emailTo = new List<string>();
                string listToItem = (string)temp[@"ToEmail"];//DataParser.GetValueFromData<string>(obj, @"ToEmail");


                emailTo.Add(listToItem);

                List<string> emailCC = new List<string>();
                string[] listCCItem = (temp[@"CCEmail"]).ToString().Split(';');//DataParser.GetValueFromData<string>(newResult.Data1, @"CCEmail").Split(';');
                foreach (var item in listCCItem)
                {
                    emailCC.Add(item);
                }

                string projectNum = "P" + (string)temp[@"ProjectID"];//DataParser.GetValueFromData<string>(newResult.Data1, @"ProjectID");
                string userName = (string)temp[@"FirstName"];//DataParser.GetValueFromData<string>(newResult.Data1, @"FirstName");
                string projectTitle = (string)temp[@"Project Name"];//DataParser.GetValueFromData<string>(newResult.Data1, @"Project Name");
                string projectStatus = (string)temp[@"Status"];//DataParser.GetValueFromData<string>(newResult.Data1, @"Status");
                string projectPCS = (string)temp[@"PCS"];//DataParser.GetValueFromData<string>(newResult.Data1, @"PCS");

                string emailBody = DataParser.GetValueFromData<string>(newResult.Data2, @"Body");
                string emailSubject = DataParser.GetValueFromData<string>(newResult.Data2, @"Subject");


                if (newResult.Data1.Count > 0)
                {
                    //string emailBodyTable1 = await _emailService.ToHTMLTable(newResult.Data3);
                    string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>()
                    {{ @"DVNUserName", userName },
                     { @"DVNProject", projectNum },
                     { @"DVNTitle", projectTitle },
                     { @"DVNStatus", projectStatus },
                     { @"DVNPCS", projectPCS } });

                    string emailSubject2 = await _emailService.Inject(emailSubject, new Dictionary<string, string>() { { @"DVNProjectNum", projectNum } });

                    EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject2, emailBody: emailBody2, CCList: emailCC);
                    await _emailService.Send(template);
                }
            }
        }

        return origResult;
    }
    public async Task<MCREDVNResult> Op_32(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<DED>(32, model);
    }
    public async Task<MCREDVNResult> Op_33(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(33, model);
    }
    public async Task<MCREDVNResult> Op_34(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(34, model);
    }
    public async Task<MCREDVNResult> Op_35(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(35, model);
    }
    public async Task<MCREDVNResult> Op_36(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(36, model);
    }
    public async Task<MCREDVNResult> Op_37(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(37, model);
    }
    public async Task<MCREDVNResult> Op_38(MCREDVNProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(38, model);
    }

    public async Task<MCREDVNResult> Op_39(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(39, model);
    }
    public async Task<MCREDVNResult> Op_40(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(40, model);
    }
    public async Task<MCREDVNResult> Op_41(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(41, model);
    }
    public async Task<MCREDVNResult> Op_42(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(42, model);
    }
    public async Task<MCREDVNResult> Op_43(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(43, model);
    }
    public async Task<MCREDVNResult> Op_44(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(44, model);
    }
    public async Task<MCREDVNResult> Op_45(MCREDVNProcedure model = null)
    {
        return await ExecuteReader<SC>(45, model);
    }
}