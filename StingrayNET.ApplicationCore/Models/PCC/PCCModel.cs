using System;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;

namespace StingrayNET.ApplicationCore.Models.PCC;

public class PCCModel : BaseDEDModel
{
    public PCCRecordTypeEnum TypeEnum => _type;
    public override string Type => Enum.GetName(_type) ?? throw new Exception("PCC Type not found");
    public string EmployeeID => _employeeID;

    public override bool IsAdmin => User?.IsSysAdmin ?? false || (User?.IsPCCAdmin ?? false);
    private PCCRecordTypeEnum _type;
    private string _employeeID = string.Empty;
    public IRepositoryXL<PCCProcedure, PCCResult> Repository { get; }
    public PCCModel(PCCRecordTypeEnum type, string employeeID, IRepositoryXL<PCCProcedure, PCCResult> repository, DEDStatusEnum dEDStatus)
    {
        _type = type;
        _employeeID = employeeID;
        Repository = repository;
        StatusCode = dEDStatus;
    }




}