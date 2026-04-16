using System;

namespace StingrayNET.ApplicationCore.CustomExceptions;

public class ForbiddenException : Exception
{

    public ForbiddenException(string message) : base(message)
    {

    }

    public ForbiddenException() : base()
    {

    }

}
