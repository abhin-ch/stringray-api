using System;

namespace StingrayNET.ApplicationCore.CustomExceptions;

public class DownstreamAPIException : Exception
{

    public DownstreamAPIException(string message) : base(message)
    {

    }

    public DownstreamAPIException(string message, Exception innerException) : base(message, innerException)
    {

    }

}
