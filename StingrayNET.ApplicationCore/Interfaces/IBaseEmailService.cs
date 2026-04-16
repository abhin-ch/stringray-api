using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using System;
using System.Threading.Tasks;
using System.Threading;

public interface IBaseEmailService
{
    public Task SendEmail(Func<CancellationToken, Task<QuickEmailTemplate>> emailFunction, User originaLuser, bool impersonating);
}