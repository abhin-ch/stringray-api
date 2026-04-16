using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Models.ExpressionSerializer;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IExpressionSerializer
{
    public Expression ParseExpression(string expression, List<string>? possibleUsers = null);

    public bool EvaluateExpression(Expression expression, Dictionary<string, List<Dictionary<string, object>>> datasets = null, Dictionary<string, Dictionary<string, Type>> datasetTypes = null);

    public bool EvaluateExpression(string expression, Dictionary<string, List<Dictionary<string, object>>> datasets = null, Dictionary<string, Dictionary<string, Type>> datasetTypes = null, List<string>? possibleUsers = null);
}
