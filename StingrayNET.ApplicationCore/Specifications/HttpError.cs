using System;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Specifications;

public class HttpError : BaseResult
{
    private ErrorResponse _error;

    public HttpError(string errorMessage) : base(null!)
    {
        _error = ErrorResponse.BuildErrorResponseAsync(new Exception(errorMessage));
        StatusCode = _error.StatusCode;
        Value = _error;
    }

    public HttpError(Exception e) : base(null!)
    {
        _error = ErrorResponse.BuildErrorResponseAsync(e);
        StatusCode = _error.StatusCode;
        Value = _error;
    }
}
