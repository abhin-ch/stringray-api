using StingrayNET.ApplicationCore.Models.WSService;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IWSService
{
    Task<StingrayWS> GetWebSocket(HttpContext context, string? sequentialSchemaName = null);

    Task<byte[]> ReceiveNext(StingrayWS ws);

    Task<T> ReceiveJson<T>(StingrayWS ws);

    Task SendJson(StingrayWS ws, byte[] jsonBytes);

    Task SendJson<T>(StingrayWS ws, T jsonObject);

    Task<byte[]> ReceiveBytes(StingrayWS ws);

    Task<string> ReceiveText(StingrayWS ws);

    Task CloseWebSocket(StingrayWS ws);

    Task<string> IssueToken(string endpoint, HttpContext context);

    Task<(bool result, string message)> ValidateToken(string token);

}
