using System;

namespace StingrayNET.ApplicationCore.CustomExceptions;

public class UnauthorizedException : Exception
{

    public UnauthorizedException(string message) : base(message)
    {

    }

}
