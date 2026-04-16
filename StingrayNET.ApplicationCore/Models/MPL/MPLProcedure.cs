using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.MPL;

public class MPLProcedure : BaseProcedure
{

    public class DEDChangeRequest
    {
        public string? ProjectID { get; set; }
        public DateTime? NDQDate { get; set; } = null;
        public DateTime? ResumeDate { get; set; } = null;
        public string? field { get; set; }
        public string? NewValue { get; set; }
        public string? OldValue { get; set; }
    }
    public CSQTable? CSQInfoList { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public List<DEDChangeRequest>? Solutions { get; set; } = null;
    public string? ProjectID { get; set; } = null;
    public string? field { get; set; } = null;
    public string? NewValue { get; set; } = null;
    public string? OldValue { get; set; } = null;
    public string? OverruledValue { get; set; } = null;
    public string? ProjectNo { get; set; } = null;
    public bool? ApprovalResp { get; set; } = null;
    public string? ProjectUpdateID { get; set; } = null;
    public string? FieldName { get; set; } = null;
    public string? Department { get; set; } = null;

    public List<MPLAcceptedID>? AcceptedID { get; set; } = null;
    public string? OldUser { get; set; } = null;
    public string? NewUser { get; set; } = null;
    public string? Comment { get; set; } = null;



}