
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.ApplicationCore.Models.CARLA;

public class ScheduleUpdateEmail
{
    public Project ProjectInfo { get; }
    public string Template => _template;
    public List<Activity> AtRisk { get; }
    public List<string> ToAddress { get; }
    public List<string> CcAddress { get; }
    private string _template;

#nullable disable
    public ScheduleUpdateEmail(Project projectInfo, string template, List<Activity> atRisk)
    {
        ProjectInfo = projectInfo;
        _template = template;
        AtRisk = atRisk;
        ToAddress = GetToAddress(projectInfo);
        CcAddress = GetCCAddress(projectInfo);
    }
#nullable enable

    private static List<string> GetToAddress(Project projectInfo)
    {
        var toList = new List<string>();
        if (projectInfo.IsNCSQ)
        {
            if (!string.IsNullOrEmpty(projectInfo.PCSLeadEmail)) toList.Add(projectInfo.PCSLeadEmail);
        }
        else
        {

            if (!string.IsNullOrEmpty(projectInfo.PMEmail)) toList.Add(projectInfo.PMEmail);
        }
        return toList;
    }

    private static List<string> GetCCAddress(Project projectInfo)
    {
        var ccList = new List<string>();
        if (projectInfo.IsNCSQ) return ccList;
        if (!string.IsNullOrEmpty(projectInfo.CommitmentOwnerEmail)) ccList.Add(projectInfo.CommitmentOwnerEmail);
        if (!string.IsNullOrEmpty(projectInfo.ContractAdminEmail)) ccList.Add(projectInfo.ContractAdminEmail);
        if (!string.IsNullOrEmpty(projectInfo.PlannerEmail)) ccList.Add(projectInfo.PlannerEmail);
        return ccList;
    }

    private string PopulateTemplate()
    {
        Dictionary<string, string> values = new Dictionary<string, string>();
        values.Add("[var1]", ProjectInfo.ProjectID);
        values.Add("[var2]", ProjectInfo.ProjectName);
        values.Add("[var3]", ProjectInfo.PM);
        values.Add("[var4]", ProjectInfo.CommitmentOwner);
        values.Add("[date]", DateTime.Now.ToString("dd-MMM-yyyy"));
        values.Add("[reason]", ProjectInfo.Reason);
        values.Add("[FragnetName]", ProjectInfo.FragnetName);
        values.Add("[Comment]", ProjectInfo.Comment);

        List<string> tempList = new List<string>();
        foreach (var csq in AtRisk.Where(e => e.NCSQ != "NCSQ"))
        {
            var temp = $"<tr><td>{csq.ActivityID}</td><td colspan='3'>{csq.Title}</td><td>{csq.CommitmentDate}</td><td>{(ProjectInfo.Removed ? "REMOVED" : csq.RevisedDate)}</td><td>{csq.Resource}</td></tr>";
            tempList.Add(temp);
        }

        foreach (var ncsq in AtRisk.Where(e => e.NCSQ == "NCSQ"))
        {
            var temp = $"<tr><td>{ncsq.ActivityID}</td><td colspan='3'>{ncsq.Title}</td><td>{ncsq.CommitmentDate}</td><td>{ncsq.RevisedDate}</td><td>{ProjectInfo.Reason}</td></tr>";
            tempList.Add(temp);
        }

        if (tempList.Count > 0)
        {
            values.Add("<!--AtRiskList-->", string.Join("", tempList));
        }
        _template = _template.Replace("\r", "").Replace("\n", "").Replace("\t", "");
        return HelperFunctions.Template.Populate(_template, values);
    }

    public static List<Activity>? GetActivities(CARLAResult result)
    {
        try
        {
            var activityList = result.Data2;
            var activityOptions = new JsonSerializerOptions
            {
                Converters = { new ActivityConverter() }
            };
            var actDict = System.Text.Json.JsonSerializer.Serialize(activityList);
            var atRisk = System.Text.Json.JsonSerializer.Deserialize<List<Activity>>(actDict, activityOptions);
            return atRisk;
        }
        catch (Exception)
        {
            return null!;
        }
    }

    public static string GetEmailTemplate(CARLAResult result)
    {
        try
        {
            return DataParser.GetValueFromData<string>(new List<object> { result.Data }, "EmailBody") ?? "";
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }
    public static Project? GetProjectInfo(CARLAResult result)
    {
        try
        {
            var project = result.Data1;
            if (project.Count > 0)
            {
                var projectOptions = new JsonSerializerOptions
                {
                    Converters = { new ProjectInfoConverter() }
                };
                var projDict = System.Text.Json.JsonSerializer.Serialize(project[0]);
                var projectInfo = System.Text.Json.JsonSerializer.Deserialize<ScheduleUpdateEmail.Project>(projDict, projectOptions);
                return projectInfo;
            }
            return null!;
        }
        catch (Exception)
        {
            return null!;
        }
    }


    public MsgTemplate? CreateMsgTemplate(string userMail)
    {
        _template = PopulateTemplate();
        return new MsgTemplate(userMail, ToAddress, Template, $"Schedule Update - Project ID: {ProjectInfo.ProjectID}", CcAddress);
    }

    public class Project
    {
        public string? PM { get; set; } = string.Empty;
        public string? PMLANID { get; set; }
        public string? PMEmail { get; set; }
        public string? CommitmentOwner { get; set; }
        public string? CommitmentOwnerLANID { get; set; }
        public string? CommitmentOwnerEmail { get; set; }
        public string? ContractAdmin { get; set; }
        public string? ContractAdminLANID { get; set; }
        public string? ContractAdminEmail { get; set; }
        public string? Planner { get; set; }
        public string? PlannerLANID { get; set; }
        public string? PlannerEmail { get; set; }
        public string? ProjectID { get; set; }
        public string? ProjectName { get; set; }
        public string? Reason { get; set; }
        public string? Comment { get; set; }
        public string? FragnetName { get; set; }
        public string? Status { get; set; }
        public string? PCSLeadName { get; set; }
        public string? PCSLeadEmail { get; set; }
        public string? NCSQ { get; set; }
        public bool IsNCSQ => NCSQ == "NCSQ" ? true : false;
        public bool Removed => Status == "Pending Removal" || Status == "Removed" ? true : false;

    }

    public class Activity
    {
        public string? ActivityID { get; set; }
        public string? Title { get; set; }
        public string? CommitmentDate { get; set; }
        public string? RevisedDate { get; set; }
        public string? Resource { get; set; }
        public string? NCSQ { get; set; }
    }
}