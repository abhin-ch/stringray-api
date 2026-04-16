namespace StingrayNET.ApplicationCore.Models.CARLA;

public abstract class IFADetails
{
    public string? ActivityID { get; set; }
    public string? DetailName { get; set; }
    public string? DetailValue { get; set; }
    public string? DetailValue1 { get; set; }

    public abstract void MapFields();
}

