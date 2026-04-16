using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.Common.ADF;
using System;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IADFService
{
    public Task<string> TriggerPipeline(TriggerRequest request);

    public Task<(bool active, string status)> PollPipeline(string runID, bool alwaysUseProduction = false);

}