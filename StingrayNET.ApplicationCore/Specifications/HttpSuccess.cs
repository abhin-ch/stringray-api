using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Specifications;

public class HttpSuccess : BaseResult
{
    public HttpSuccess(object body) : base(body) { }
}
