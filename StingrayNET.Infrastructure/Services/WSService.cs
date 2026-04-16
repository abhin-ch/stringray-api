using System;
using System.Net.WebSockets;
using System.Text.Json;
using StingrayNET.ApplicationCore.Interfaces;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore.CustomExceptions;
using System.Text.RegularExpressions;
using StingrayNET.ApplicationCore.Models.WSService;
using Microsoft.Extensions.Configuration;
using System.Threading.Tasks;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Specifications;
using System.Threading;
using System.Linq;
using s = Serilog;
using System.ComponentModel;

namespace StingrayNET.Infrastructure.Services
{
    public class WSService : IWSService
    {
        private readonly IConfiguration _configuration;
        private readonly IDatabase<SC> _dbService;
        private readonly IIdentityService _identityService;
        private readonly IKVService _kvService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly s.ILogger _logger;

        public WSService(IConfiguration configuration, IDatabase<SC> dbService, IIdentityService identityService, IKVService kvService,
        IHttpContextAccessor httpContextAccessor, s.ILogger logger)
        {
            _configuration = configuration;
            _dbService = dbService;
            _identityService = identityService;
            _kvService = kvService;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        public async Task<StingrayWS> GetWebSocket(HttpContext context, string? sequentialSchemaName = null)
        {
            if (context.WebSockets.IsWebSocketRequest)
            {
                //Extract JWT in query string
                if ((bool)context.Request.Query?.ContainsKey("token"))
                {
                    //Validate token signature
                    var validateResult = await ValidateToken(context.Request.Query["token"]);
                    if (validateResult.result)
                    {
                        string postApiPath = Regex.Match(context.Request.Path.Value, @"(?<=(api)\/).+$").Value;

                        List<SqlParameter> parameters = new List<SqlParameter>()
                        {
                            new SqlParameter()
                            {
                                ParameterName = @"@Operation",
                                SqlDbType = System.Data.SqlDbType.Int,
                                Value = 1
                            }
                        };

                        if (!string.IsNullOrEmpty(sequentialSchemaName))
                        {
                            parameters.Add(new SqlParameter()
                            {
                                ParameterName = @"@SequentialChannel",
                                SqlDbType = System.Data.SqlDbType.VarChar,
                                Value = sequentialSchemaName
                            });
                        }

                        else
                        {
                            parameters.Add(new SqlParameter()
                            {
                                ParameterName = @"@Endpoint",
                                SqlDbType = System.Data.SqlDbType.VarChar,
                                Value = postApiPath
                            });
                        }

                        // DBRequest request = new DBRequest(@"stng.SP_Admin_Websocket", parameters);
                        List<Dictionary<string, object>> response = (await _dbService.ExecuteReaderAsync(@"stng.SP_Admin_Websocket", parameters)).Select(x => (Dictionary<string, object>)x).ToList();

                        StingrayWS ws = null;
                        if (response.Count > 0)
                        {
                            ws = new StingrayWS(await context.WebSockets.AcceptWebSocketAsync(), response);
                            await SendJson(ws, SequentialSchema.Build(response));

                        }

                        else
                        {
                            ws = new StingrayWS(await context.WebSockets.AcceptWebSocketAsync());
                        }

                        return ws;
                    }

                    else
                    {
                        throw new Exception(validateResult.message);
                    }

                }

                else
                {
                    throw new Exception(@"Request does not contain a WS token");
                }

            }

            else
            {
                throw new Exception(@"Request is not WebSockets compatible");
            }
        }

        private byte[] GetBuffer()
        {
            return new byte[1024 * 1024 * 20];
        }

        private async Task<(WebSocketReceiveResult result, byte[] resultBytes)> Receive(StingrayWS ws)
        {
            byte[] buffer = GetBuffer();

            if (ws.ConnectionActive)
            {
                // if (DateTime.UtcNow - ws.LastMessageReceived <= TimeSpan.FromMinutes(Convert.ToInt32(_configuration["WSTimeout"])))
                // {
                WebSocketReceiveResult result = await ws.WebSocket.ReceiveAsync(new ArraySegment<byte>(buffer), CancellationToken.None);
                ws.LastMessageReceived = DateTime.UtcNow;

                return (result, buffer);
                // }

                // else
                // {
                //     await CloseWebSocket(ws);
                // }
            }

            return (new WebSocketReceiveResult(0, WebSocketMessageType.Close, true), buffer);

        }

        public async Task<T> ReceiveJson<T>(StingrayWS ws)
        {
            _logger.Information("ReceiveJson");

            var (receiveResult, buffer) = await Receive(ws);

            _logger.Information("Received Buffer");

            if (!receiveResult.CloseStatus.HasValue)
            {
                return JsonSerializer.Deserialize<T>(Encoding.UTF8.GetString(buffer, 0, receiveResult.Count));
            }

            else
            {
                return default(T);
            }
        }

        public async Task SendJson<T>(StingrayWS ws, T jsonObject)
        {
            byte[] sendBytes = Encoding.UTF8.GetBytes(JsonSerializer.Serialize<T>(jsonObject));

            await SendJson(ws, sendBytes);
        }

        public async Task SendJson(StingrayWS ws, byte[] jsonBytes)
        {
            await ws.WebSocket.SendAsync(
                new ArraySegment<byte>(jsonBytes, 0, jsonBytes.Length),
                WebSocketMessageType.Text,
                true,
                CancellationToken.None);
        }

        public async Task<string> ReceiveText(StingrayWS ws)
        {
            return Encoding.UTF8.GetString(await ReceiveBytes(ws));
        }

        public async Task<byte[]> ReceiveBytes(StingrayWS ws)
        {
            var (receiveResult, buffer) = await Receive(ws);

            if (!receiveResult.CloseStatus.HasValue)
            {
                byte[] returnArray = new byte[receiveResult.Count];
                Array.Copy(buffer, returnArray, receiveResult.Count);

                return returnArray;
            }

            else
            {
                return null;
            }
        }

        public async Task CloseWebSocket(StingrayWS ws)
        {
            await ws.WebSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, string.Empty, CancellationToken.None);
            ws.ConnectionActive = false;
        }

        public async Task<string> IssueToken(string endpoint, HttpContext context)
        {
            List<SqlParameter> parameters = new List<SqlParameter>()
            {
                new SqlParameter()
                {
                    ParameterName = @"@Operation",
                    SqlDbType = System.Data.SqlDbType.Int,
                    Value = 2
                },
                new SqlParameter()
                {
                    ParameterName = @"@EmployeeID",
                    SqlDbType = System.Data.SqlDbType.VarChar,
                    Value = await _identityService.GetEmployeeID(context)
                },
                new SqlParameter()
                {
                    ParameterName = @"@Endpoint",
                    SqlDbType = System.Data.SqlDbType.VarChar,
                    Value = endpoint
                }
            };

            //Create entry in DB
            List<Dictionary<string, object>> response = (await _dbService.ExecuteReaderAsync(@"stng.SP_Admin_EphemeralToken", parameters
            )).Select(x => (Dictionary<string, object>)x).ToList();

            if (response.Count == 0)
            {
                throw new Exception(@"Unsuccessful token creation");
            }

            if (response[0].ContainsKey("ReturnMessageUnauthorized"))
            {
                throw new UnauthorizedException(string.Format(@"Unsuccessful token creation - {0}", response[0]["ReturnMessageUnauthorized"].ToString()));
            }

            else if (response[0].ContainsKey("ReturnMessage"))
            {
                throw new ValidationException(string.Format(@"Unsuccessful token creation - {0}", response[0]["ReturnMessage"].ToString()));
            }

            string id = response[0]["id"].ToString();
            DateTime expiry = Convert.ToDateTime(response[0]["Expiry"]);

            //Claims list
            List<Claim> claims = new List<Claim>()
            {
                new Claim(type: "id", value: id)
            };

            //Create and return JWT
            SymmetricSecurityKey key = new SymmetricSecurityKey(Convert.FromBase64String(_kvService.GetSecret(_configuration["SymmetricKeySecretName"], _configuration["KeyVault:ServiceURI"])));
            SigningCredentials cred = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            JwtSecurityToken token = new JwtSecurityToken(claims: claims, expires: expiry, signingCredentials: cred);

            return new JwtSecurityTokenHandler().WriteToken(token);

        }

        public async Task<(bool result, string message)> ValidateToken(string token)
        {
            JwtSecurityTokenHandler handler = new JwtSecurityTokenHandler();
            TokenValidationParameters validationParams = new TokenValidationParameters()
            {
                ValidateLifetime = false,
                ValidateAudience = false,
                ValidateIssuer = false,
                IssuerSigningKey = new SymmetricSecurityKey(Convert.FromBase64String(_kvService.GetSecret(_configuration["SymmetricKeySecretName"]
                , _configuration["KeyVault:ServiceURI"])))
            };

            var verificationResult = await handler.ValidateTokenAsync(token, validationParams);

            if (verificationResult.IsValid)
            {
                //Check for claims
                if (!verificationResult.Claims.ContainsKey(@"id"))
                {
                    return (false, @"Missing required claims");
                }

                string id = verificationResult.Claims[@"id"].ToString();

                //Check for expiration
                List<Dictionary<string, object>> response = (await _dbService.ExecuteReaderAsync(@"stng.SP_Admin_EphemeralToken",
                    new List<SqlParameter>()
                    {
                        new SqlParameter()
                        {
                            ParameterName = @"@Operation",
                            SqlDbType = System.Data.SqlDbType.Int,
                            Value = 1
                        },
                        new SqlParameter()
                        {
                            ParameterName = @"@ID",
                            SqlDbType = System.Data.SqlDbType.VarChar,
                            Value = id
                        }

                    }
                )).Select(x => (Dictionary<string, object>)x).ToList();

                if (response.Count == 0)
                {
                    return (false, @"Token does not exist or has expired");
                }

                else if (response[0].ContainsKey(@"ReturnMessage"))
                {
                    return (false, response[0][@"ReturnMessage"].ToString());
                }

                _httpContextAccessor.HttpContext.Items[@"EmployeeID"] = response[0][@"EmployeeID"].ToString();
                return (true, @"Valid token");
            }

            else
            {
                return (false, verificationResult.Exception.Message);
            }

        }

        public async Task<byte[]> ReceiveNext(StingrayWS ws)
        {
            throw new NotImplementedException();
        }

    }
}
