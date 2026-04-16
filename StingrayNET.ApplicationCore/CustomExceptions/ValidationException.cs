using System;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.CustomExceptions;

public class ValidationException : Exception
{
    public List<string>? ExceptionList { get; private set; }

    public ValidationException(string message, List<string>? exceptionList = null) : base(message)
    {
        ExceptionList = exceptionList;
    }

}
