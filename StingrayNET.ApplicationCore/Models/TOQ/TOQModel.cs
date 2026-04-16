using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using System;

namespace StingrayNET.ApplicationCore.Models.TOQ;

public class TOQModel : BaseDEDModel
{
    private TOQType _type;
    private string? _typeName;
    private string _employeeID = string.Empty;
    public TOQType TypeEnum => _type;
    public override string Type => _typeName ?? throw new Exception("TOQ Type not found");
    public string EmployeeID => _employeeID;
    public IRepositoryL<Procedure, TOQResult> Repository { get; }

    public override bool IsAdmin => User?.IsSysAdmin ?? false || (User?.IsTOQAdmin ?? false);

    public TOQModel(TOQType type, int tmid, string employeeID, string statusValue, IRepositoryL<Procedure, TOQResult> repository)
    {
        _typeName = SetType(type);
        _type = type;
        ID = tmid;
        _employeeID = employeeID;
        StatusCode = Enum.Parse<DEDStatusEnum>(statusValue);
        Repository = repository;
    }

    private static string? SetType(TOQType type)
    {
        return Enum.GetName(typeof(TOQType), type);
    }


}
public enum TOQType
{
    STD,
    MDCC,
    PSA,
    EMERG,
    MDOE,
    MDER,
    MDGEN,
    MDSECC,
    CONSULT,
    SVN,
    STDOE,
    REWORK
}