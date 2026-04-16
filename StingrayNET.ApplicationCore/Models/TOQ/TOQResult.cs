using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.HelperFunctions;
using System.Linq;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.TOQ;

public class TOQResult : BaseOperation
{
    public EmailResult? Email { get; set; }

    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public List<string>? BCC { get; set; }
        public string? EmailBody { get; set; }
        public string? EmailSubject { get; set; }
    }

    public class ValidationResult
    {
        public string Name { get; set; }
        public List<string> Messages { get; set; }
        public bool HasErrors => Messages.Count > 0;

        public ValidationResult(string name)
        {
            Name = name;
            Messages = new List<string>();
        }
    }

    public static ValidationResult[] ValidateStatus(string? statusCode, TOQResult result)
    {
        var statusErrors = new ValidationResult("StatusErrors");
        var ramErrors = new ValidationResult("RAM Errors");
        var ramRevisionErrors = new ValidationResult("RAM Revision Errors");

        try
        {
            DEDStatusEnum status;
            if (Enum.TryParse<DEDStatusEnum>(statusCode, true, out status))
            {
                switch (status)
                {
                    case DEDStatusEnum.ICORR:
                    case DEDStatusEnum.INIT:
                        {

                            var emergentID = DataParser.GetValueFromData<string>(result.Data1, "EmergentID");
                            var workType = DataParser.GetValueFromData<string>(result.Data1, "WorkType");
                            if (workType is not null && workType.Equals("EMERGENT") && (emergentID is null || emergentID == ""))//need to also see if checkbox is selected
                            {
                                statusErrors.Messages.Add("Emergent ID Not Provided");
                            }

                            var hasClassVEstimate = DataParser.GetValueFromData<bool>(result.Data1, "HasClassVEstimate");
                            if (!hasClassVEstimate)
                            {
                                statusErrors.Messages.Add("ClassV Estimate not linked");
                            }

                            var totalAttachments = DataParser.GetValueFromData<int>(result.Data2, "TotalTDSAttachments");
                            if (totalAttachments == 0)
                            {
                                statusErrors.Messages.Add("TDS attachment required");
                            }

                            if (result.Data3 != null && result.Data3.Any())
                            {
                                var toqMain = DataParser.GetModelFromObject<TOQMain>(result.Data3[0]);
                                if (toqMain is not null)
                                {
                                    if (!toqMain.IsValid())
                                    {
                                        statusErrors.Messages.Add($"Missing - {toqMain.ErrorMessage}");
                                    }
                                }
                            }

                            if (result.Data4 != null && result.Data4.Any())
                            {
                                var hasTierOneVendor = DataParser.GetValueFromData<bool>(result.Data4, "hasTierOneVendor");

                                var PreviouslyRAMApproved = DataParser.GetValueFromData<bool>(result.Data4, "PreviouslyRAMApproved");
                                var TotalRAMAttachments = DataParser.GetValueFromData<int>(result.Data4, "TotalRAMAttachments");

                                var EBSRAMLock = DataParser.GetValueFromData<bool>(result.Data4, "EBSRAMLock");

                                if (PreviouslyRAMApproved == false && EBSRAMLock != true && hasTierOneVendor != true)
                                {
                                    ramErrors.Messages.Add($"RAM PDE Estimating required to be populated due bucket owner not being selected. If previously not approved, please Submit to RAM and must be locked by EBS before proceeding");
                                }
                                if (PreviouslyRAMApproved == true && TotalRAMAttachments == 0 && hasTierOneVendor != true)
                                {
                                    ramErrors.Messages.Add($"Previously Approved RAM must have an upload");
                                }
                            }

                            break;
                        }
                    case DEDStatusEnum.AOEVA:
                        {
                            var vendorAwardID = DataParser.GetValueFromData<string>(result.Data1, "VendorAwardID");
                            var LinkedSDQ = DataParser.GetValueFromData<string>(result.Data1, "LinkedSDQ");
                            var JustificationForNaLinkedSDQ = DataParser.GetValueFromData<string>(result.Data1, "JustificationForNaLinkedSDQ");
                            if (string.IsNullOrEmpty(vendorAwardID))
                            {
                                statusErrors.Messages.Add($"Vendor not selected. Please select a vendor in the Award Tab and Save.");
                            }
                            else if (string.IsNullOrEmpty(LinkedSDQ))
                            {
                                statusErrors.Messages.Add($"Please link an SDQ in the Award Tab or select N/A with provided justification and then save.");
                            }
                            else if (LinkedSDQ == "N/A" && string.IsNullOrEmpty(JustificationForNaLinkedSDQ))
                            {
                                statusErrors.Messages.Add($"Justification required for N/A SDQ selection in the Vendor Award Tab");
                            }

                            var submissionCount = DataParser.GetValueFromData<int>(result.Data2, "SubmissionCount");
                            var comparisonEBSRAMLock = DataParser.GetValueFromData<bool>(result.Data3, "ComparisonEBSRAMLock");
                            var VendorLowestCostOption = DataParser.GetValueFromData<bool>(result.Data3, "VendorLowestCostOption");
                            var VendorBucketOwner = DataParser.GetValueFromData<bool>(result.Data3, "VendorBucketOwner");
                            var hasSubmissionGreaterThan500k = DataParser.GetValueFromData<bool>(result.Data3, "hasSubmissionGreaterThan500k");

                            // Check if bid is competitive
                            if (submissionCount > 1)
                            {
                                // Check if RAM is exempt
                                bool isRAMExempt = (VendorBucketOwner || VendorLowestCostOption) && !hasSubmissionGreaterThan500k;

                                // If not exempt, RAM must be locked - with specific error messages
                                if (!isRAMExempt && !comparisonEBSRAMLock)
                                {
                                    if (hasSubmissionGreaterThan500k)
                                    {
                                        ramErrors.Messages.Add("This TOQ has a submission exceeding $500k - RAM approval is required. RAM must be submitted and locked before progressing to SM.");
                                    }
                                    else if (!VendorLowestCostOption && !VendorBucketOwner)
                                    {
                                        ramErrors.Messages.Add("Since neither the lowest cost option is selected nor is this vendor the bucket owner, RAM approval is required. RAM must be submitted and locked.");
                                    }
                                    else if (!VendorLowestCostOption)
                                    {
                                        ramErrors.Messages.Add("Since the lowest cost option is not selected, RAM approval is required. RAM must be submitted and locked.");
                                    }
                                    else if (!VendorBucketOwner)
                                    {
                                        ramErrors.Messages.Add("Since the selected vendor is not the bucket owner, RAM approval is required. RAM must be submitted and locked.");
                                    }
                                }
                            }

                            if (result.Data4 != null && result.Data4.Any())
                            {
                                var toqMain = DataParser.GetModelFromObject<TOQMain>(result.Data4[0]);
                                if (toqMain is null)
                                {
                                    ramRevisionErrors.Messages.Add("TOQ Revision in the RAM Tab is not populated.");
                                }
                                else
                                {
                                    if (!toqMain.IsValidRAMRevision())
                                    {
                                        ramRevisionErrors.Messages.Add($"{toqMain.ErrorMessage}");
                                    }
                                }
                            }
                        }
                        break;

                    case DEDStatusEnum.AEBSP:
                        {
                            var vssCode = DataParser.GetValueFromData<string>(result.Data1, "VSSCode");
                            if (vssCode != "CO")
                            {
                                statusErrors.Messages.Add($"Vendor submission not completed.");
                            }
                            break;
                        }
                    case DEDStatusEnum.ACC:
                        {
                            var svnCount = DataParser.GetValueFromData<int>(result.Data1, "HasSVN");
                            if (svnCount > 0)
                            {
                                statusErrors.Messages.Add($"Cannot initiate Revision until all SVNs are Approved and Complete.");
                            }
                            break;
                        }
                    case DEDStatusEnum.ADPR:
                        {
                            var NumDateNotApproved = DataParser.GetValueFromData<int>(result.Data1, "NumDateNotApproved");
                            if (NumDateNotApproved <= 0)
                            {
                                statusErrors.Messages.Add($"Cannot send to EBS for Partial Review without a New Partial Row ( Date Approved is blank )");
                            }
                            break;
                        }
                    default:
                        {
                            statusErrors.Messages.Add($"StatusCode {status} not configured for validation");
                            break;
                        }
                }
            }
            else
            {
                statusErrors.Messages.Add("StatusCode missing in parameter Value1 - Contact System Admin");
            }
        }
        catch (Exception ex)
        {
            statusErrors.Messages.Add(ex.Message);
        }

        return new[] { statusErrors, ramErrors, ramRevisionErrors };
    }
}