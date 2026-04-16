using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.Models;

namespace StingrayNET.Application.Modules.TOQ.Workflow;

public abstract class StatusTOQ : BaseStatus<TOQModel>
{
    protected IRepositoryL<Procedure, TOQResult> _repository;
    public StatusTOQ(TOQModel model, IRepositoryL<Procedure, TOQResult> repository) : base(model)
    {
        _repository = repository;
    }

    public StatusTOQ(DEDStatusEnum statusCode, string name) : base(statusCode, name) { }

}