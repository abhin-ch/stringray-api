using StingrayNET.ApplicationCore.Abstractions;
using System;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.ER;
public class ERProcedure : BaseProcedure
{

    public class Assess
    {
        public string? id { get; set; }
        public string? name { get; set; }
        public bool value { get; set; }
    }
    public List<Assess>? Assessments { get; set; } = null;
    public bool? Completed { get; set; } = false;
    public bool? InHouse { get; set; } = false;
    public string? ERID { get; set; }
    public string? UniqueID { get; set; } = null;
    public string? ID { get; set; }
    public string? Comment { get; set; }
    public string? SearchText { get; set; }
    public string? DeliverableID { get; set; }
    public string? VendorID { get; set; }
    public string? Resource { get; set; }
    public string? ResourceType { get; set; }
    public double? EstimatedHours { get; set; }
    public string? ERDeliverableID { get; set; }
    public string? Risk { get; set; }
    public long? UniqueIDNum { get; set; }
    public long? Section { get; set; }
    public string? ProjectID { get; set; }
    public string? ActivityID { get; set; }
    public DateTime? ERTCD { get; set; } = null;
    public DateTime? ERDueDate { get; set; } = null;
    public DateTime? FiftyTCD { get; set; } = null;
    public DateTime? NinetyTCD { get; set; } = null;
    public string? Assessment { get; set; }
    public string? Prerequisite { get; set; }
    public string? StatusShort { get; set; } = null;
    public bool? isAdmin { get; set; } = null;
    public bool? ScheduleBuilt { get; set; } = false;
    public bool? AtRisk { get; set; } = false;
    public bool? Primary { get; set; } = false;
    public string? SectionName { get; set; }
    public long? Department { get; set; }
    public bool? DED { get; set; } = false;
    public bool? ProjectRequired { get; set; } = false;
    public DateTime? ERDueDateOverride { get; set; } = null;
    public bool? OverrideERDueDateCheck { get; set; } = false;
    public string? AdminOptionText { get; set; } = null;
    public string? Reason { get; set; } = null;
    public DateTime? DateFrom { get; set; } = null;
    public DateTime? DateTo { get; set; } = null;
    public bool? Exception { get; set; }
    public int? KPI { get; set; }

}
