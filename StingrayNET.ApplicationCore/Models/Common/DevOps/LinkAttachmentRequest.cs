using System;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.Common.DevOps;

public class LinkAttachmentRequest
{
    public List<DevOpsAttachment> Attachments { get; set; }
    public int WI { get; set; }

}

