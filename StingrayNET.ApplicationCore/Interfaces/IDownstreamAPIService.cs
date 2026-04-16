using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;

namespace StingrayNET.ApplicationCore.Interfaces;

public enum DownstreamAPIContentType
{
    None = 0,
    JSON = 1,
    PatchJSON = 2,
    Binary = 3

}

public interface IDownstreamAPIService
{
    Task<KeyValuePair<HttpStatusCode, string>> DownstreamAPICall(Uri uri, HttpMethod httpMethod, AuthenticationHeaderValue authHeader = null, string content = null, DownstreamAPIContentType contentType = DownstreamAPIContentType.None);

}
