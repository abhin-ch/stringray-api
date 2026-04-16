
using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.TOQLite;
public class TOQLiteProcedure : BaseProcedure
{
    public class Qual
    {
        public string? id { get; set; }
        public string? name { get; set; }
        public bool value { get; set; }
    }
    public List<Qual>? Qualifications { get; set; } = null;

    public string? CurrentUser { get; set; } = null;
    public string? ProjectSearch { get; set; } = null;

    public bool? SingleRow { get; set; } = false;
    public string? TOQLiteID { get; set; } = null;
    public long? VendorDeliverableID { get; set; } = null;
    public string? Section { get; set; } = null;
    public string? ProjectNo { get; set; } = null;
    public string? VendorTOQID { get; set; } = null;

    public int? VendorTOQRevision { get; set; } = null;
    public DateTime? PCT50Date { get; set; } = null;
    public DateTime? PCT90Date { get; set; } = null;
    public bool? ERLevelDates { get; set; } = null;
    public bool? FromERModule { get; set; } = null;
    public DateTime? VendorResponseDate { get; set; } = null;
    public string? ER { get; set; } = null;

    public long? BPDeliverableID { get; set; } = null;

    public double? DeliverableHours { get; set; } = null;
    public string? VendorShort { get; set; } = null;
    public string? Deliverable { get; set; } = null;

    public string? Activity { get; set; } = null;
    public double? ActivityHours { get; set; } = null;
    public DateTime? ActivityStart { get; set; } = null;
    public DateTime? ActivityFinish { get; set; } = null;
    public long? VendorDeliverableActivityID { get; set; } = null;
    public string? ActivityType { get; set; } = null;

    public double? DeliverableCost { get; set; } = null;
    public string? StatusShort { get; set; } = null;
    public string? CurrentStatus { get; set; } = null;

    public string? Comment { get; set; } = null;
    public string? Vendor { get; set; } = null;
    public string? ActivityID { get; set; } = null;
    public double? BlendedRate { get; set; } = null;
    public string? DeliverableName { get; set; } = null;
    public List<TOQLiteSortOrder>? SortOrder { get; set; } = null;
    public bool? SortUpdate { get; set; } = false;

    public string? Outage { get; set; } = null;
    public string? Department { get; set; } = null;
    public string? TemplateName { get; set; } = null;
    public bool? SeeAll { get; set; } = null;
    public string? Qualification { get; set; } = null;
    public string? Scope { get; set; } = null;
    public string? VendorID { get; set; } = null;


}