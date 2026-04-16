

namespace StingrayNET.ApplicationCore.Models.Plugin;
public class SessionTaskParameter
{
    public string SessionTask { get; private set; }
    public string ParameterName { get; private set; }
    public string ParameterValue { get; private set; }
    public SessionTaskParameter(string sessionTask, string parameterName, string parameterValue)
    {
        SessionTask = sessionTask;
        ParameterName = parameterName;
        ParameterValue = parameterValue;
    }
}