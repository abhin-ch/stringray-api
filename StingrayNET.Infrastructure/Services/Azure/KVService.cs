using Azure.Core;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using Microsoft.Extensions.Configuration;
using StingrayNET.ApplicationCore.Interfaces;
using System;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Services.Azure;

public class KVService : IKVService
{
    private readonly IConfiguration _config;
    public KVService(IConfiguration config)
    {
        _config = config;
    }

    public ClientSecretCredential GetCredential()
    {
        return new ClientSecretCredential
        (
            tenantId: _config["AzureAd:TenantId"],
            clientId: _config["AzureAd:ClientId"],
            clientSecret: GetSecret(_config["KeyVault:SPSecret"], _config["KeyVault:ServiceUri"])
        );
    }

    public async Task<string> GetToken(string[] scopes)
    {
        return (await GetCredential().GetTokenAsync(new TokenRequestContext(scopes))).Token;
    }

    public string GetSecret(string secretName, string secretURI)
    {
        //Get clientSecret
        SecretClientOptions options = new SecretClientOptions()
        {
            Retry =
                {
                    Delay = TimeSpan.FromSeconds(2),
                    MaxDelay = TimeSpan.FromSeconds(16),
                    MaxRetries = 5,
                    Mode = RetryMode.Exponential
                }
        };

        return new SecretClient(new Uri(secretURI), new DefaultAzureCredential(), options).GetSecret(secretName).Value.Value.ToString();

    }

}
