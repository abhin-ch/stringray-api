using System;

namespace StingrayNET.ApplicationCore.CustomExceptions;

public class BadRequestException : Exception
{

    public BadRequestException(string message) : base(message)
    {

    }

}
