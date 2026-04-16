using System;
using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.Rest;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using StingrayNET.ApplicationCore.Models.Common.ADF;
using StingrayNET.ApplicationCore.CustomExceptions;
using System.Linq;
namespace StingrayNET.Infrastructure.Services.Azure
{
    public class ADFService : IADFService
    {
        private readonly IKVService _KVService;
        private readonly IConfiguration _config;

        public ADFService(IKVService kvService, IConfiguration config)
        {
            _KVService = kvService;
            _config = config;
        }


        public async Task<string> TriggerPipeline(TriggerRequest request)
        {
            try
            {

                var client = await GetClient((bool)request.AlwaysUseProduction);
                string rg = (bool)request.AlwaysUseProduction ? _config["ADFOverride:RG"] : _config["AzureAd:RG"];
                string factoryName = (bool)request.AlwaysUseProduction ? _config["ADFOverride:Name"] : _config["ADF:Name"];

                string runID = (await client.Pipelines.CreateRunWithHttpMessagesAsync(
                    resourceGroupName: rg, factoryName: factoryName, pipelineName: request.PipelineName, parameters: request.Parameters)).Body.RunId;

                return runID;

            }

            catch (Exception e)
            {
                throw new DownstreamAPIException(e.Message, e);
            }
        }

        public async Task<(bool active, string status)> PollPipeline(string runID, bool alwaysUseProduction = false)
        {
            try
            {
                var client = await GetClient(alwaysUseProduction);
                string rg = alwaysUseProduction ? _config["ADFOverride:RG"] : _config["AzureAd:RG"];
                string factoryName = alwaysUseProduction ? _config["ADFOverride:Name"] : _config["ADF:Name"];
                PipelineRun run = client.PipelineRuns.Get(rg, factoryName, runID);

                if (run.Status == @"InProgress" || run.Status == @"Queued")
                {
                    return (active: true, status: run.Status);
                }

                else
                {

                    if (run.Status != @"Succeeded")
                    {
                        RunFilterParameters filterParams = new RunFilterParameters(DateTime.UtcNow.AddMinutes(-10), DateTime.UtcNow.AddMinutes(10));

                        ActivityRunsQueryResponse queryResponse = await client.ActivityRuns.QueryByPipelineRunAsync(resourceGroupName: rg, factoryName: factoryName, runId: runID, filterParameters: filterParams);

                        //Throw exception
                        throw new Exception(queryResponse.Value.First().Error.ToString());
                    }

                    return (active: false, status: run.Status);
                }

            }

            catch (Exception e)
            {
                throw new DownstreamAPIException(e.Message, e);
            }

        }

        private async Task<DataFactoryManagementClient> GetClient(bool alwaysUseProduction = false)
        {
            ServiceClientCredentials cred = new TokenCredentials(await _KVService.GetToken(new string[] { @"https://management.azure.com/.default" }));

            return new DataFactoryManagementClient(cred) { SubscriptionId = _KVService.GetSecret(alwaysUseProduction ? _config["ADFOverride:PRODSubscriptionSecret"] : _config["KeyVault:SubscriptionSecret"], _config["KeyVault:ServiceUri"]) };

        }

    }

}