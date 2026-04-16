using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.TOQ;

namespace StingrayNET.Application.Modules.TOQ.Workflow;

public interface ITOQStatusProvider
{
    List<BaseStatus<TOQModel>> GetTOQStatusOptions(TOQModel model);
}

public class TOQStatusProvider : ITOQStatusProvider
{
    readonly IRepositoryL<Procedure, TOQResult>? _repository;

    public TOQStatusProvider(IRepositoryL<Procedure, TOQResult> repository)
    {
        _repository = repository;
    }

    public List<BaseStatus<TOQModel>> GetTOQStatusOptions(TOQModel model)
    {
        BaseStatus<TOQModel>? status = null!;

        switch (model.TypeEnum)
        {
            case TOQType.STDOE:
            case TOQType.STD:
            case TOQType.MDOE:
            case TOQType.MDER:
            case TOQType.MDGEN:
            case TOQType.MDCC:
                status = new StatusTOQStandard(model);
                break;
            // These types follow Consulting flow
            case TOQType.CONSULT:
            case TOQType.MDSECC:
                status = new StatusTOQConsulting(model);
                break;

            // Emergent flow
            case TOQType.EMERG:
                status = new StatusTOQEmergent(model);
                break;

            // SVN flow
            case TOQType.SVN:
                status = new StatusTOQSVN(model);
                break;

            // Rework flow
            case TOQType.REWORK:
                status = new StatusTOQRework(model);
                break;

            default:
                throw new ArgumentException($"TOQ Type: {model.TypeEnum} is not recognized.");
        }
        return status.Options;
    }


}
