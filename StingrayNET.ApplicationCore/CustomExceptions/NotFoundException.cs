using System;

namespace StingrayNET.ApplicationCore.CustomExceptions;

public class NotFoundException : Exception
{

    public NotFoundException(string message = "Not Found") : base(message)
    {

    }

}
