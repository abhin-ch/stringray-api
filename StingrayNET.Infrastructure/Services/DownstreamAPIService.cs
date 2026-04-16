using StingrayNET.ApplicationCore.Interfaces;
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Net;
using System.Text;

namespace StingrayNET.Infrastructure.Services;

public class DownstreamAPIService : IDownstreamAPIService
{
    public async Task<KeyValuePair<HttpStatusCode, string>> DownstreamAPICall(Uri uri, HttpMethod httpMethod, AuthenticationHeaderValue authHeader = null, string content = null, DownstreamAPIContentType contentType = DownstreamAPIContentType.None)
    {

        //Instantiate HTTPClient
        HttpClient httpClient = new HttpClient();

        //Instantiate HTTP Request
        HttpRequestMessage httpRequest = new HttpRequestMessage();

        httpRequest.RequestUri = uri;
        httpRequest.Method = httpMethod;
        httpRequest.Headers.Host = uri.Host;

        if (authHeader != null)
        {
            httpRequest.Headers.Authorization = authHeader;
        }

        if (!string.IsNullOrEmpty(content))
        {
            if (contentType == DownstreamAPIContentType.None)
            {
                throw new ArgumentNullException(@"contentType", @"If content is provided, contentType must not be None");
            }
            else
            {

                httpRequest.Content = new StringContent(content, Encoding.UTF8, GetContentTypeFromEnum(contentType));

            }
        }

        //Send request; await response
        HttpResponseMessage httpResponse = await httpClient.SendAsync(httpRequest);

        return new KeyValuePair<HttpStatusCode, string>(httpResponse.StatusCode, await httpResponse.Content.ReadAsStringAsync());

    }

    private string GetContentTypeFromEnum(DownstreamAPIContentType contentType)
    {
        switch (contentType)
        {
            case DownstreamAPIContentType.JSON:
                {
                    return @"application/json";
                }

            case DownstreamAPIContentType.PatchJSON:
                {
                    return @"application/json-patch+json";
                }

            case DownstreamAPIContentType.Binary:
                {
                    return @"application/octet-stream";
                }

        }

        return null;
    }

}

