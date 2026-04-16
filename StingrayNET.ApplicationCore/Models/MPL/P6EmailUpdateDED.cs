using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.HelperFunctions;

namespace StingrayNET.ApplicationCore.Models.MPL;

public class P6EmailUpdateDED
{

    public string Template => _template;

    public List<string> ToAddress { get; }
    public List<string> CcAddress { get; }
    private string _template;

#nullable disable
    //  private string PopulateTemplate()
    // {


    //     List<string> tempList = new List<string>();
    //     foreach (var csq in AtRisk.Where(e => e.NCSQ != "NCSQ"))
    //     {
    //         var temp = $"<tr><td>{csq.ActivityID}</td><td colspan='3'>{csq.Title}</td><td>{csq.CommitmentDate}</td><td>{(ProjectInfo.Removed ? "REMOVED" : csq.RevisedDate)}</td><td>{csq.Resource}</td></tr>";
    //         tempList.Add(temp);
    //     }

    //     foreach (var ncsq in AtRisk.Where(e => e.NCSQ == "NCSQ"))
    //     {
    //         var temp = $"<tr><td>{ncsq.ActivityID}</td><td colspan='3'>{ncsq.Title}</td><td>{ncsq.CommitmentDate}</td><td>{ncsq.RevisedDate}</td><td>{ProjectInfo.Reason}</td></tr>";
    //         tempList.Add(temp);
    //     }

    //     if (tempList.Count > 0)
    //     {
    //         values.Add("<!--AtRiskList-->", string.Join("", tempList));
    //     }
    //     _template = _template.Replace("\r", "").Replace("\n", "").Replace("\t", "");
    //     return HelperFunctions.Template.Populate(_template, values);
    // }
    public static string GetEmailTemplate(MPLResult result)
    {
        try
        {
            return DataParser.GetValueFromData<string>(new List<object> { result.Data3[0] }, "EmailBody");
        }
        catch (Exception)
        {
            return string.Empty;
        }
    }

}