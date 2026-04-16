using System;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.TOQ;

public class TOQMain
{
    // TDS Header
    public string UniqueID { get; set; }
    public int TMID { get; set; }
    public int Rev { get; set; }
    public string RequestFrom { get; set; }
    public string StatusID { get; set; }
    public DateTime StatusDate { get; set; }
    public string ClassVUniqueID { get; set; }
    public string Title { get; set; }
    public string TDSNo { get; set; }
    public string Comment { get; set; }
    public string Project { get; set; }
    public dynamic? VendorSubmissionDate { get; set; }
    public dynamic? VendorClarificationDate { get; set; }
    public string ContractType { get; set; }
    public string Resource { get; set; }
    public string ScopeOfWork { get; set; }
    public string TDSRev { get; set; }
    public string Type { get; set; }
    public string TypeID { get; set; }
    public string ScopeManagedBy { get; set; }
    public string Phase { get; set; }
    public string Customer { get; set; }
    public string VendorWorkTypeID { get; set; }
    public string WorkTypeID { get; set; }
    public dynamic? VendorStartDate { get; set; }
    public string PCS { get; set; }
    public string OE { get; set; }
    public string SM { get; set; }
    public string DM { get; set; }
    public string DMEP { get; set; }
    public bool? VendorsSelected { get; set; }

    // RAM PDE
    public bool? PreviouslyRAMApproved { get; set; }
    public dynamic? DateOfRevision { get; set; }
    public string Location { get; set; }
    public string BriefStatementofScope { get; set; }
    public string FundingSource { get; set; }
    public bool? BudgetHolderHaveApprovedFunding { get; set; }
    public bool? ConfirmProjectBudgetFormHasBeenPrepared { get; set; }
    public bool? HasRequiredScopeofWorkBeenOfferedInternally { get; set; }
    public bool? EBSRAMLock { get; set; }
    public string PreviousSimilarProjectsExperience { get; set; }
    public string RecommendedResourcingStrategy { get; set; }
    public int TotalRAMAttachments { get; set; }


    // RAM Revision
    public string ReasonForRevision { get; set; }
    public string AdditionalInfoForRevision { get; set; }
    public int TOQRevisionAmount { get; set; }
    public int ScopeDecision { get; set; }
    public int TrendDecision { get; set; }


    private List<string> _missingFields { get; set; }

    public bool IsValid()
    {
        bool isValid = true;
        _missingFields = new List<string>();
        _errorMessage = "";
        if (string.IsNullOrEmpty(Title))
        {
            _missingFields.Add(nameof(Title));
        }

        if (string.IsNullOrEmpty(TDSNo))
        {
            _missingFields.Add(nameof(TDSNo));
        }

        if (string.IsNullOrEmpty(UniqueID))
        {
            _missingFields.Add(nameof(UniqueID));
        }

        if (string.IsNullOrEmpty(RequestFrom))
        {
            _missingFields.Add(nameof(RequestFrom));
        }

        if (string.IsNullOrEmpty(StatusID))
        {
            _missingFields.Add(nameof(StatusID));
        }

        if (StatusDate == default)
        {
            _missingFields.Add(nameof(StatusDate));
        }

        if (string.IsNullOrEmpty(ClassVUniqueID))
        {
            //_missingFields.Add(nameof(ClassVUniqueID));
        }

        if (string.IsNullOrEmpty(Convert.ToString(VendorSubmissionDate)))
        {
            _missingFields.Add(nameof(VendorSubmissionDate));
        }

        if (string.IsNullOrEmpty(Convert.ToString(VendorClarificationDate)))
        {
            _missingFields.Add(nameof(VendorClarificationDate));
        }

        if (string.IsNullOrEmpty(Resource))
        {
            //_missingFields.Add(nameof(Resource));
        }

        if (string.IsNullOrEmpty(TDSRev))
        {
            _missingFields.Add(nameof(TDSRev));
        }

        if (string.IsNullOrEmpty(TypeID))
        {
            _missingFields.Add(nameof(TypeID));
        }

        if (string.IsNullOrEmpty(ScopeManagedBy))
        {
            _missingFields.Add(nameof(ScopeManagedBy));
        }

        // For 3 Consulting + 2 OE/ADE TOQ types, entering phase should be not required
        if (string.IsNullOrEmpty(Phase) && Type is not ("CONSULT" or "MDCC" or "MDSECC" or "STDOE" or "MDOE"))
        {
            _missingFields.Add(nameof(Phase));
        }

        if (string.IsNullOrEmpty(Customer))
        {
            _missingFields.Add(nameof(Customer));
        }

        if (string.IsNullOrEmpty(VendorWorkTypeID))
        {
            _missingFields.Add(nameof(VendorWorkTypeID));
        }

        if (string.IsNullOrEmpty(Convert.ToString(VendorStartDate)))
        {
            _missingFields.Add(nameof(VendorStartDate));
        }

        if (string.IsNullOrEmpty(OE))
        {
            _missingFields.Add(nameof(OE));
        }

        if (string.IsNullOrEmpty(PCS))
        {
            _missingFields.Add(nameof(PCS));
        }

        if (string.IsNullOrEmpty(SM))
        {
            _missingFields.Add(nameof(SM));
        }

        if (string.IsNullOrEmpty(Project))
        {
            _missingFields.Add(nameof(Project));
        }
        else if (Project.Length != 5)
        {
            _missingFields.Add($"Project must be a valid 5-digit number");
        }

        if (!VendorsSelected.HasValue || VendorsSelected.Value == false)
        {
            _missingFields.Add($"Vendor(s) Selected");
        }

        _errorMessage = $"Missing fields: {string.Join(", ", _missingFields)}";

        if (_missingFields.Count > 0)
        {
            isValid = false;
        }

        return isValid;
    }
    public bool IsValidRAMPDE()
    {
        bool isValid = true;
        _missingFields = new List<string>();
        _errorMessage = "";


        if (PreviouslyRAMApproved == null)
        {
            _errorMessage = "RAM PDE Estimating required to be populated due to bucket owner not being selected.";
            return false;
        }

        if (PreviouslyRAMApproved == true)
        {
            if (TotalRAMAttachments > 0)
            {
                return true;
            }
            else
            {
                _errorMessage = "For previously approved RAM, please upload approving email or supporting documentation";
                return false;
            }

        }
        if (EBSRAMLock != true)
        {
            _errorMessage = "RAM PDE Estimating needs to be approved by EBS and locked before proceeding.";
            return false;
        }

        if (PreviouslyRAMApproved == true)
        {
            if (string.IsNullOrEmpty(Convert.ToString(DateOfRevision)))
            {
                _missingFields.Add(nameof(DateOfRevision));
            }

            if (string.IsNullOrEmpty(Location))
            {
                _missingFields.Add(nameof(Location));
            }

            if (string.IsNullOrEmpty(BriefStatementofScope))
            {
                _missingFields.Add(nameof(BriefStatementofScope));
            }

            if (string.IsNullOrEmpty(FundingSource))
            {
                _missingFields.Add(nameof(FundingSource));
            }

            if (string.IsNullOrEmpty(Convert.ToString(BudgetHolderHaveApprovedFunding)))
            {
                _missingFields.Add(nameof(BudgetHolderHaveApprovedFunding));
            }

            if (string.IsNullOrEmpty(Convert.ToString(ConfirmProjectBudgetFormHasBeenPrepared)))
            {
                _missingFields.Add(nameof(ConfirmProjectBudgetFormHasBeenPrepared));
            }

            if (string.IsNullOrEmpty(Convert.ToString(HasRequiredScopeofWorkBeenOfferedInternally)))
            {
                _missingFields.Add(nameof(HasRequiredScopeofWorkBeenOfferedInternally));
            }

            if (string.IsNullOrEmpty(PreviousSimilarProjectsExperience))
            {
                _missingFields.Add(nameof(PreviousSimilarProjectsExperience));
            }

            if (string.IsNullOrEmpty(RecommendedResourcingStrategy))
            {
                _missingFields.Add(nameof(RecommendedResourcingStrategy));
            }
        }

        _errorMessage = $"Missing fields: {string.Join(", ", _missingFields)}";

        if (_missingFields.Count > 0)
        {
            isValid = false;
        }

        return isValid;
    }

    public bool IsValidRAMRevision()
    {
        bool isValid = true;
        _missingFields = new List<string>();
        _errorMessage = "";


        if (string.IsNullOrEmpty(ReasonForRevision))
        {
            _missingFields.Add(nameof(ReasonForRevision));
        }

        if (string.IsNullOrEmpty(AdditionalInfoForRevision))
        {
            _missingFields.Add(nameof(AdditionalInfoForRevision));
        }

        if (TOQRevisionAmount < 0)
        {
            _missingFields.Add(nameof(TOQRevisionAmount));
        }



        // ScopeDecision + TrendDecision must equal 100
        if (ScopeDecision + TrendDecision != 100)
        {
            _missingFields.Add("Total of ScopeDecision and TrendDecision must equal 100%");
        }
        _errorMessage = $"Missing fields: {string.Join(", ", _missingFields)}";

        if (_missingFields.Count > 0)
        {
            isValid = false;
        }

        return isValid;
    }

    public string ErrorMessage => _errorMessage;

    private string _errorMessage { get; set; }
}