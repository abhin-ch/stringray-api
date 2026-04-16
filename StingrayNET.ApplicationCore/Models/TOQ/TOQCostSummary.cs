using System;
using System.Text.Json.Serialization;

public class TOQCostSummary
{
    [JsonPropertyName("TotalCost")]
    public decimal TotalCost { get; set; }

    [JsonPropertyName("NewTOQCommitmentDate")]
    public string NewTOQCommitmentDateString { get; set; }

    [JsonIgnore]
    public DateTime? NewTOQCommitmentDate
    {
        get
        {
            if (string.IsNullOrEmpty(NewTOQCommitmentDateString))
                return null;
            return DateTime.TryParse(NewTOQCommitmentDateString, out DateTime date) ? date : null;
        }
    }

    [JsonPropertyName("DeliverableEndDate")]
    public string DeliverableEndDateString { get; set; }

    [JsonIgnore]
    public DateTime? DeliverableEndDate
    {
        get
        {
            if (string.IsNullOrEmpty(DeliverableEndDateString))
                return null;
            return DateTime.TryParse(DeliverableEndDateString, out DateTime date) ? date : null;
        }
    }

    [JsonPropertyName("TOQEndDate")]
    public string TOQEndDateString { get; set; }

    [JsonIgnore]
    public DateTime? TOQEndDate
    {
        get
        {
            if (string.IsNullOrEmpty(TOQEndDateString))
                return null;
            return DateTime.TryParse(TOQEndDateString, out DateTime date) ? date : null;
        }
    }

    [JsonPropertyName("BrucePowerCommitment")]
    public string BrucePowerCommitment { get; set; }

    public bool IsValid()
    {
        // Validate "DQ" or "NDQ" commitments require a NewTOQCommitmentDate
        if ((BrucePowerCommitment == "DQ" || BrucePowerCommitment == "NDQ") && !NewTOQCommitmentDate.HasValue)
        {
            return false;
        }
        return true;
    }
}