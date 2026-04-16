using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.MPL;

public class MPLResult : BaseOperation
{
    public MPLResult()
    {
        CIIDataList = new List<CIIData>();
        CVDataList = new List<CVData>();
        NewCIIBudget = new List<Budget>();
        NewCVBudget = new List<Budget>();
        RemainingBudget = new List<Budget>();
    }
    public List<object> Data4 { get; set; }
    public object Data5 { get; set; }
    public object Data6 { get; set; }
    public object Data7 { get; set; }
    public object Data8 { get; set; }

    public bool DocumentSuccess { get; set; }
    public string DocType { get; set; }
    public string LastUpdated { get; set; }
    public MPL MPL { get; set; }
    public List<object> MPLList { get; set; }
    public List<CIIData> CIIDataList { get; set; }
    public List<CVData> CVDataList { get; set; }
    public FinancialData Financial { get; set; }
    public List<Budget> NewCIIBudget { get; set; }
    public List<Budget> NewCVBudget { get; set; }
    public List<Budget> RemainingBudget { get; set; }

    public string? ChangeRequestID { get; set; }
    public string? Department { get; set; }

    public class CIIData
    {
        public string FragnetName { get; set; }
        public string ActivityID { get; set; }
        public string ActivityName { get; set; }
        public string PDO { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
        public string RoC { get; set; }
        public string Header { get; set; }
        public string SDS { get; set; }
        public string Total { get; set; }
        public string DateSort { get; set; }
        public string DateSortS { get; set; }

    }
    public class CVData
    {
        public string FragnetID { get; set; }
        public string FragnetName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

    }
    public class FinancialData
    {
        public string ProjectID { get; set; }
        public string ProjectBudget { get; set; }
        public string TotalCost { get; set; }
        public string PMPCCost { get; set; }
        public string SCCost { get; set; }
    }
    public class Budget
    {
        public string FragnetName { get; set; }
        public string Unit { get; set; }
        public string Phase { get; set; }
        public string LabourHrs { get; set; }
        public string LawHrs { get; set; }

    }
    public EmailResult? Email { get; set; }

    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public string? EmailBody { get; set; }
    }
}
