using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IExpressionRepository
{
    public Task<bool> EvaluateExpression(string expressionName, Dictionary<string, Dictionary<string, object>>? datasetParams = null, List<string>? possibleUsers = null);

}
