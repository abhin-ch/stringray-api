
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.SST;

public class SSTProcedure : BaseProcedure
{
    public class CommentID
    {
        public string? UUID { get; set; }
    }
    public class SSTIDnum
    {
        public string? UUID { get; set; }
    }
    public string? SSTID { get; set; }
    public string? SSTNo { get; set; }
    public string? CommentType { get; set; }
    public int? PreDoseCost { get; set; }
    public int? Dose { get; set; }
    public int? DoseMREM { get; set; }
    public int? SingleExecutionCost { get; set; }
    public int? ImpairmentCount { get; set; }
    public string? ImpairmentUnit { get; set; }
    public bool? ImpairmentNA { get; set; }

    public int? ChannelRejectionCount { get; set; }
    public string? ChannelRejectionUnit { get; set; }
    public bool? ChannelRejectionNA { get; set; }

    public List<SSTIDnum>? SSTIDList { get; set; } = null;
    public List<CommentID>? SSTCloneIDList { get; set; } = null;
    public string? Comment { get; set; }
    public long? SSTCommentID { get; set; }
}
