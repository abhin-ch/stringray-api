using System;
using System.Threading.Tasks;
using System.Text.Json;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore.CustomExceptions;

namespace StingrayNET.ApplicationCore.Models;
public class ErrorResponse
{
    public string ErrorMessage { get; private set; }
    public int StatusCode { get; private set; }

    public string ErrorID { get; private set; }

    public List<string>? SupplementaryMessages { get; private set; }

    private ErrorResponse(string errorMessage, int statusCode, string errorID)
    {
        ErrorMessage = errorMessage;
        StatusCode = statusCode;
        ErrorID = errorID;
    }

    public ErrorResponse(Exception e)
    {
        var properties = GetProperties(e);
        string errorID = Guid.NewGuid().ToString();

        ErrorMessage = properties[@"ErrorMessage"].ToString();
        StatusCode = Convert.ToInt32(properties[@"StatusCode"]);
        ErrorID = errorID;
        SupplementaryMessages = (List<string>)properties[@"SupplementaryMessages"];
    }


    public async Task<string> ToJSON()
    {
        return await Task.Run(() => JsonSerializer.Serialize(this));
    }

    public static ErrorResponse BuildErrorResponseAsync(Exception e)
    {
        string errorID = Guid.NewGuid().ToString();

        var returnDict = GetProperties(e);
        return new ErrorResponse(errorMessage: returnDict["ErrorMessage"].ToString() ?? "Error Message not found", statusCode: Convert.ToInt32(returnDict["StatusCode"]), errorID: errorID);
    }

    private static Dictionary<string, object> GetProperties(Exception e)
    {
        string errorMessage = null!;
        int statusCode = 500;
        List<string>? supplementaryMessages = null;

        switch (e)
        {
            case SqlException:
                {
                    if (e.Message.ToLower().Contains("server was not found"))
                    {
                        errorMessage = @"SQL Service not available";
                        statusCode = 503;
                    }

                    else
                    {
                        errorMessage = @"SQL-side error occurred";
                        statusCode = 510;
                    }
                    break;
                }

            case ValidationException:
                {
                    ValidationException validationException = (ValidationException)e;

                    errorMessage = String.Format(@"Validation check(s) failed - {0}", e.Message);
                    statusCode = 425;

                    supplementaryMessages = validationException.ExceptionList;

                    break;
                }
            case DownstreamAPIException:
                {
                    errorMessage = @"Downstream API call failed";
                    statusCode = 530;

                    break;
                }

            case BadRequestException:
                {
                    errorMessage = string.Format(@"Bad request - {0}", e.Message);
                    statusCode = 400;

                    break;
                }

            case UnauthorizedException:
                {
                    errorMessage = string.Format(@"Unauthorized - {0}", e.Message);
                    statusCode = 401;

                    break;
                }

            case NotFoundException:
                {
                    errorMessage = @"Not Found";
                    statusCode = 404;
                    break;
                }

            case ForbiddenException:
                {
                    errorMessage = string.Empty;
                    statusCode = 403;
                    break;
                }

            default:
                {
                    errorMessage = @"Server Side Exception occurred";
                    statusCode = 520;
                    break;
                }

        }

        return new Dictionary<string, object>()
            {
                { "ErrorMessage", errorMessage },
                {"StatusCode",statusCode },
                {"SupplementaryMessages", supplementaryMessages }
            };
    }

}

