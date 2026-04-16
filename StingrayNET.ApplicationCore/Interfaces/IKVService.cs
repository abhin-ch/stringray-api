using Azure.Identity;
using System.Threading.Tasks;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IKVService
{
    ClientSecretCredential GetCredential();
    string GetSecret(string secretName, string secretURI);

    Task<string> GetToken(string[] scopes);
}
