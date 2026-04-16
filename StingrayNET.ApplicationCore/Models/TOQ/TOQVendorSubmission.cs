using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.PCC;
using StingrayNET.ApplicationCore.Models.Common;
using System;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.TOQ;

public class TOQVendorSubmission
{
    public string TOQNumber { get; set; }
    public string ProjectManager { get; set; }
    public string Location { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string OrderNumber { get; set; }
    public string ContractNumber { get; set; }
    public string TOQReasonID { get; set; }
    public string FundingTypeID { get; set; }

    public string TOQStartDate { get; set; }
    public string TOQEndDate { get; set; }


    private List<string> _missingFields { get; set; }

    public bool IsValid()
    {
        bool isValid = true;
        _missingFields = new List<string>();
        _errorMessage = "";

        if (string.IsNullOrEmpty(TOQNumber))
        {
            _missingFields.Add(nameof(TOQNumber));
        }
        if (string.IsNullOrEmpty(Location))
        {
            _missingFields.Add(nameof(Location));
        }
        if (string.IsNullOrEmpty(ProjectManager))
        {
            _missingFields.Add(nameof(ProjectManager));
        }
        if (string.IsNullOrEmpty(ContractNumber))
        {
            _missingFields.Add("PurchaseContractNumber");
        }
        if (string.IsNullOrEmpty(Email))
        {
            _missingFields.Add(nameof(Email));
        }
        if (string.IsNullOrEmpty(Phone))
        {
            _missingFields.Add(nameof(Phone));
        }
        if (string.IsNullOrEmpty(TOQReasonID))
        {
            _missingFields.Add("ReasonForTOQ");
        }
        if (string.IsNullOrEmpty(FundingTypeID))
        {
            _missingFields.Add("FundingType");
        }
        if (string.IsNullOrEmpty(TOQStartDate))
        {
            _missingFields.Add(nameof(TOQStartDate));
        }
        if (string.IsNullOrEmpty(TOQEndDate))
        {
            _missingFields.Add(nameof(TOQEndDate));
        }

        // Validate dates
        if (DateTime.TryParse(TOQStartDate, out var startDate) &&
            DateTime.TryParse(TOQEndDate, out var endDate))
        {
            if (startDate > endDate)
            {
                _missingFields.Add("TOQ End Date must be after TOQ Start Date");
            }
        }
        else
        {
            _missingFields.Add("TOQ End Date must be after TOQ Start Date");
        }

        _errorMessage = $"Missing fields: {Environment.NewLine}{string.Join(Environment.NewLine, _missingFields)}";

        if (_missingFields.Count > 0)
        {
            isValid = false;
        }

        return isValid;
    }

    public string ErrorMessage => _errorMessage;

    private string _errorMessage { get; set; }
}