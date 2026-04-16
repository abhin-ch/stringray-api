using StingrayNET.ApplicationCore.Models.ExpressionSerializer;
using StingrayNET.ApplicationCore.Interfaces;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System;
using System.Linq;
using Microsoft.AspNetCore.Http;

namespace StingrayNET.Infrastructure.Services;

public class ExpressionSerializer : IExpressionSerializer
{
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IIdentityService _identityService;

    public ExpressionSerializer(IHttpContextAccessor httpContextAccessor, IIdentityService identityService)
    {
        _httpContextAccessor = httpContextAccessor;
        _identityService = identityService;
    }

    public Expression ParseExpression(string expression, List<string>? possibleUsers = null)
    {
        //Declare working dictionaries
        Dictionary<string, Term> terms = new Dictionary<string, Term>();
        Dictionary<string, ElementaryExpression> elemExps = new Dictionary<string, ElementaryExpression>();
        Dictionary<string, CompositeExpression> compositeExps = new Dictionary<string, CompositeExpression>();

        int termCounter = 1;
        int elemExpCounter = 1;
        int compExpCounter = 1;

        //Copy expression str
        List<char> workingCharArray = new List<char>();
        foreach (char c in expression)
        {
            workingCharArray.Add(c);
        }

        string workingExpressionStr = new string(workingCharArray.ToArray());
        workingCharArray.Clear();

        //Check if all [] and () are properly closed
        BracketCheck(workingExpressionStr);
        BracketCheck(workingExpressionStr, '[');

        //Substitute fields
        string pattern = @"\[[^\[\]]+\]\.\[[^\[\]]+\]";
        string val;

        while (Regex.IsMatch(workingExpressionStr, pattern))
        {
            val = Regex.Match(workingExpressionStr, pattern).Value;

            terms[$"@T{termCounter}@"] = new Term(TermType.Field, val);

            workingExpressionStr = workingExpressionStr.Replace(val, $"@T{termCounter}@");

            termCounter++;
        }

        //Substitute Qualified Strings
        pattern = @"(\"")[^\""]+(\"")";

        while (Regex.IsMatch(workingExpressionStr, pattern))
        {
            val = Regex.Match(workingExpressionStr, pattern).Value;

            terms[$"@T{termCounter}@"] = new Term(TermType.Constant, val.Replace(@"""", string.Empty), true);
            workingExpressionStr = workingExpressionStr.Replace(val, $"@T{termCounter}@");

            termCounter++;
        }

        //Substitute Booleans
        pattern = @"true|false";

        while (Regex.IsMatch(workingExpressionStr, pattern))
        {
            val = Regex.Match(workingExpressionStr, pattern).Value;

            terms[$"@T{termCounter}@"] = new Term(TermType.Constant, val);
            workingExpressionStr = workingExpressionStr.Replace(val, $"@T{termCounter}@");

            termCounter++;
        }

        //Substitute Datetimes
        pattern = @"dt\([0-9\,]+\)";

        while (Regex.IsMatch(workingExpressionStr, pattern))
        {
            val = Regex.Match(workingExpressionStr, pattern).Value;

            terms[$"@T{termCounter}@"] = new Term(TermType.Constant, val);
            workingExpressionStr = workingExpressionStr.Replace(val, $"@T{termCounter}@");

            termCounter++;
        }

        //Substitute Keywords
        pattern = string.Join("|", Enum.GetNames(typeof(Keyword)));

        while (Regex.IsMatch(workingExpressionStr, pattern, RegexOptions.IgnoreCase))
        {
            val = Regex.Match(workingExpressionStr, pattern, RegexOptions.IgnoreCase).Value;

            terms[$"@T{termCounter}@"] = new Term(TermType.Keyword, val);
            workingExpressionStr = workingExpressionStr.Replace(val, $"@T{termCounter}@");

            termCounter++;
        }

        //Substitute Field Functions
        pattern = string.Format(@"({0})\((\@T[0-9]+\@)\)", string.Join("|", Enum.GetNames(typeof(FieldFunction))));

        while (Regex.IsMatch(workingExpressionStr, pattern, RegexOptions.IgnoreCase))
        {
            val = Regex.Match(workingExpressionStr, pattern, RegexOptions.IgnoreCase).Value;

            //Map @T{Num} to actual term in terms
            string fieldFuncField = Regex.Match(val, @"\@T[0-9]+\@").Value;
            if (terms.ContainsKey(fieldFuncField))
            {
                terms[$"@T{termCounter}@"] = new Term(TermType.FieldFunc, val, fieldFuncTerm: terms[fieldFuncField]);
            }

            else
            {
                throw new Exception(string.Format(@"Unable to map Field Function field argument for {0}", val));
            }

            workingExpressionStr = workingExpressionStr.Replace(val, $"@T{termCounter}@");

            termCounter++;
        }

        //Check if any non-@ qualified strings remain
        foreach (char c in workingExpressionStr)
        {
            workingCharArray.Add(c);
        }

        string nonQualCheckStr = new string(workingCharArray.ToArray());
        workingCharArray.Clear();

        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"and|or", string.Empty);
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, string.Format(@"({0})(?=\()", string.Join("|", Enum.GetNames(typeof(DatasetFunction)))), string.Empty, RegexOptions.IgnoreCase);
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\@T[0-9]+\@", string.Empty);
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\=|\<|\>|\!", string.Empty);
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\(|\)", string.Empty);
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\s", @",");
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\,{2,}", @",");
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\[[^\[\]]+\]", string.Empty);
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"(?<![A-Za-z])[0-9\.]+", @",");
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"\,{2,}", @",");
        nonQualCheckStr = Regex.Replace(nonQualCheckStr, @"^\,|\,$", string.Empty);

        if (nonQualCheckStr.Length > 0)
        {
            throw new Exception($"Unable to parse terms \"{nonQualCheckStr}\" in provided expression. They may be unqualified fields/strings or misspelt keywords");
        }

        //Substitute Numbers
        pattern = @"(?<!T)[0-9\.]+(?!\@)";

        MatchCollection matches = Regex.Matches(workingExpressionStr, pattern);

        foreach (Match match in matches)
        {
            val = match.Value;

            terms[$"@T{termCounter}@"] = new Term(TermType.Constant, val);
            val = val.Replace(@".", @"\.");
            workingExpressionStr = Regex.Replace(workingExpressionStr, $"(?<![0-9]|T){val}(?![0-9]|\\@)", $"@T{termCounter}@");

            termCounter++;
        }

        //Substitute elementary workingExpressionStrs
        pattern = @"\@T[0-9]+\@[\s\>\<\=\!]+\@T[0-9]+\@";

        while (Regex.IsMatch(workingExpressionStr, pattern))
        {
            val = Regex.Match(workingExpressionStr, pattern).Value;

            MatchCollection elemTerms = Regex.Matches(val, @"\@T[0-9]+\@");

            Term leftTerm = terms[elemTerms[0].Value];
            Term rightTerm = terms[elemTerms[1].Value];

            ComparisonOperator comparisonOperator = ElementaryExpression.GetComparisonOperator(val);

            //Identify if right or left Term (Or both) have a user keyword
            bool rightUser = false;
            if (rightTerm.TermType == TermType.Keyword && rightTerm.Value.ToString().ToLower() == Keyword.User.ToString().ToLower())
            {
                rightUser = true;
            }

            bool leftUser = false;
            if (leftTerm.TermType == TermType.Keyword && leftTerm.Value.ToString().ToLower() == Keyword.User.ToString().ToLower())
            {
                leftUser = true;
            }

            if (possibleUsers?.Count > 0 && (rightUser || leftUser))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append(@"(");
                int userCounter = 1;
                foreach (string possibleUser in possibleUsers)
                {
                    if (userCounter > 1)
                    {
                        sb.Append($" or ");
                    }

                    terms[$"@T{termCounter}@"] = new Term(TermType.Constant, possibleUser, true);

                    if (leftUser)
                    {
                        sb.Append($"@T{termCounter}@");
                    }

                    else
                    {
                        sb.Append(elemTerms[0].Value);
                    }

                    sb.Append($" {ElementaryExpression.GetComparisonOperatorText(comparisonOperator)} ");

                    if (rightUser)
                    {
                        sb.Append($"@T{termCounter}@");
                    }

                    else
                    {
                        sb.Append(elemTerms[1].Value);
                    }

                    userCounter++;
                    termCounter++;
                }

                //Flush sb and replace val
                sb.Append(")");
                workingExpressionStr = workingExpressionStr.Replace(val, sb.ToString());
            }

            else
            {
                elemExps[$"@E{elemExpCounter}@"] = new ElementaryExpression(leftTerm, comparisonOperator, rightTerm);
                workingExpressionStr = workingExpressionStr.Replace(val, $"@E{elemExpCounter}@");

                elemExpCounter++;
            }
        }

        //Evaluate Dataset functions first
        var datasetFuncExtract = ExtractDatasetFunctions(workingExpressionStr, elemExps);
        workingExpressionStr = datasetFuncExtract.workingExpressionStr;
        elemExps = datasetFuncExtract.elemExps;

        //Remove spaces/returns from the string
        workingExpressionStr = Regex.Replace(workingExpressionStr, @"\s", string.Empty);

        //Replace ands with ampersands and ors with vertical lines
        workingExpressionStr = Regex.Replace(workingExpressionStr, @"and", @"&", RegexOptions.IgnoreCase);
        workingExpressionStr = Regex.Replace(workingExpressionStr, @"or", @"|", RegexOptions.IgnoreCase);

        //Process brackets and Composite Expressions
        while (workingExpressionStr.Contains(@"("))
        {
            //Remove superfluous brackets
            workingExpressionStr = RemoveSuperfluousBrackets(workingExpressionStr);

            //Identify anything that is not a bracket, EDSC, number, or logical operator and throw exception
            if (Regex.IsMatch(workingExpressionStr, @"[^\@EDSCT0-9\&\|\(\)]+"))
            {
                throw new Exception($"Unable to parse characters {Regex.Match(workingExpressionStr, @"[^\@EDSCT0-9\&\|\(\)]+").Value} in provided expression");
            }

            //Bracket logical operations according to boolean algebra laws         
            while (Regex.IsMatch(workingExpressionStr, @"(?<=\()[@EDSC0-9\|\&]+(?=\))"))
            {
                Match bracketMatch = Regex.Match(workingExpressionStr, @"(?<=\()[@EDSC0-9\|\&]+(?=\))");

                //If multiple logical operators 
                if (bracketMatch.Value.Count(x => (x == '&' || x == '|')) > 1)
                {
                    //Bracket first AND expression
                    if (bracketMatch.Value.Count(x => x == '&') > 0)
                    {
                        Match andMatch = Regex.Match(bracketMatch.Value, @"[@EDSC0-9]+(\&)[@EDSC0-9]+");

                        workingExpressionStr = workingExpressionStr.Replace(andMatch.Value, $"({andMatch.Value})");
                    }

                    //Bracket first OR expression
                    else
                    {
                        Match orMatch = Regex.Match(bracketMatch.Value, @"[@EDSC0-9]+(\|)[@EDSC0-9]+");

                        workingExpressionStr = workingExpressionStr.Replace(orMatch.Value, $"({orMatch.Value})");
                    }

                    break;

                }

                //if just one logical operator in a bracketed expression, replace with a composite expression
                else if (bracketMatch.Value.Count(x => (x == '&' || x == '|')) == 1)
                {
                    compositeExps[$"@C{compExpCounter}@"] = new CompositeExpression(bracketMatch.Value);

                    workingExpressionStr = workingExpressionStr.Replace(bracketMatch.Value, $"@C{compExpCounter}@");

                    compExpCounter++;

                    break;
                }

            }
        }

        //All brackets should be removed by now. Consolidate remaining composite expressions according to boolean algebra
        while (Regex.IsMatch(workingExpressionStr, @"[@EDSC0-9]+(\&)[@EDSC0-9]+"))
        {
            Match match = Regex.Match(workingExpressionStr, @"[@EDSC0-9]+(\&)[@EDSC0-9]+");

            compositeExps[$"@C{compExpCounter}@"] = new CompositeExpression(match.Value);

            workingExpressionStr = workingExpressionStr.Replace(match.Value, $"@C{compExpCounter}@");

            compExpCounter++;
        }

        while (Regex.IsMatch(workingExpressionStr, @"[@EDSC0-9]+(\|)[@EDSC0-9]+"))
        {
            Match match = Regex.Match(workingExpressionStr, @"[@EDSC0-9]+(\|)[@EDSC0-9]+");

            compositeExps[$"@C{compExpCounter}@"] = new CompositeExpression(match.Value);

            workingExpressionStr = workingExpressionStr.Replace(match.Value, $"@C{compExpCounter}@");

            compExpCounter++;
        }

        return new Expression(terms, elemExps, compositeExps, expression, workingExpressionStr);

    }

    public bool EvaluateExpression(Expression exp, Dictionary<string, List<Dictionary<string, object>>> datasets, Dictionary<string, Dictionary<string, Type>> datasetTypes = null)
    {
        //Declare stack
        List<string> stack = new List<string>();

        //Declare working result and broken comp exp dicts
        Dictionary<string, bool> results = new Dictionary<string, bool>();
        Dictionary<string, LogicalOperator> compExps = new Dictionary<string, LogicalOperator>();

        //Add top expression to stack
        stack.Add(exp.TopExpression);

        //Process stack
        while (stack.Count > 0)
        {
            string stackItem = stack[stack.Count - 1];

            //Process if stackItem is Composite
            if (exp.CompositeExpressions.ContainsKey(stackItem))
            {
                CompositeExpression compExp = exp.CompositeExpressions[stackItem];

                //If in compExps, attempt to evaluate with children results. Throw exception if children results do not exist
                if (compExps.ContainsKey(stackItem))
                {
                    //Try to get child results
                    if (!results.ContainsKey(compExp.LeftTerm))
                    {
                        throw new Exception($"{compExp.LeftTerm} was not evaluated prior to its parent");
                    }

                    else if (!results.ContainsKey(compExp.RightTerm))
                    {
                        throw new Exception($"{compExp.RightTerm} was not evaluated prior to its parent");
                    }

                    //If they exist, evaluate
                    if (compExps[stackItem] == LogicalOperator.AND)
                    {
                        results[stackItem] = results[compExp.LeftTerm] && results[compExp.RightTerm];
                    }

                    else
                    {
                        results[stackItem] = results[compExp.LeftTerm] || results[compExp.RightTerm];
                    }

                    //Delete stackItem from Stack
                    stack.RemoveAt(stack.Count - 1);
                }

                //Otherwise, break the compExp and add to stack
                else
                {
                    //If same term type, order does not matter. Otherwise, ensure composites are last
                    bool leftFirst = true;
                    if (compExp.LeftTermType != compExp.RightTermType)
                    {
                        if (compExp.LeftTermType == CompositeExpressionTermType.Composite)
                        {
                            leftFirst = false;
                        }
                    }

                    if (leftFirst)
                    {

                        stack.Add(compExp.LeftTerm);
                        stack.Add(compExp.RightTerm);

                    }

                    else
                    {
                        stack.Add(compExp.RightTerm);
                        stack.Add(compExp.LeftTerm);
                    }

                    //Add to compExps
                    compExps[stackItem] = compExp.LogicalOperator;

                }
            }

            //Process if stackItem is Elementary
            else if (exp.ElementaryExpressions.ContainsKey(stackItem))
            {
                //First, check if expression's already been parsed earlier in the stack
                if (!results.ContainsKey(stackItem))
                {
                    //If DatasetFunction property is not null, evaluate in a loop
                    if (exp.ElementaryExpressions[stackItem].DatasetFunction != null)
                    {
                        Dictionary<int, bool> dsFunctionResults = new Dictionary<int, bool>();
                        int datasetIndex = 0;

                        bool endofDataset = false;

                        while (!endofDataset)
                        {
                            var iter = EvaluateElementaryExpression(exp, stackItem, datasets, datasetTypes, datasetIndex);

                            dsFunctionResults[datasetIndex] = iter.result;
                            endofDataset = iter.endOfDataset;

                            datasetIndex++;
                        }

                        if (exp.ElementaryExpressions[stackItem].DatasetFunction == DatasetFunction.Every)
                        {
                            results[stackItem] = dsFunctionResults.Count == dsFunctionResults.Where(x => x.Value).Count();
                        }

                        else if (exp.ElementaryExpressions[stackItem].DatasetFunction == DatasetFunction.Any)
                        {
                            results[stackItem] = dsFunctionResults.Where(x => x.Value).Count() > 0;
                        }

                        else
                        {
                            throw new Exception($"{exp.ElementaryExpressions[stackItem].DatasetFunction} is not a handled Dataset Function");
                        }
                    }

                    else
                    {
                        results[stackItem] = EvaluateElementaryExpression(exp, stackItem, datasets, datasetTypes).result;
                    }

                }

                //Delete stackItem from Stack
                stack.RemoveAt(stack.Count - 1);
            }

            //Throw exception if neither
            else
            {
                throw new Exception($"{stackItem} is of an unknown Expression type. Cannot evaluate");
            }

        }

        return results[exp.TopExpression];

    }

    public bool EvaluateExpression(string exp, Dictionary<string, List<Dictionary<string, object>>> datasets, Dictionary<string, Dictionary<string, Type>> datasetTypes = null, List<string>? possibleUsers = null)
    {
        return EvaluateExpression(ParseExpression(exp, possibleUsers), datasets, datasetTypes);
    }

    private (bool result, bool endOfDataset) EvaluateElementaryExpression(Expression exp, string elemID, Dictionary<string, List<Dictionary<string, object>>> datasets, Dictionary<string, Dictionary<string, Type>> datasetTypes = null, int datasetIndex = 0)
    {
        //By default, not at endofDataset
        bool endofDataset = false;

        //Obtain elementary expression
        ElementaryExpression elemExp = exp.ElementaryExpressions[elemID];

        //Substitute terms in expression
        List<string> expressionSides = new List<string>() { @"left", @"right" };
        Dictionary<string, (Type type, object obj)> expressionTerms = new Dictionary<string, (Type type, object obj)>();

        foreach (string expressionSide in expressionSides)
        {
            Term workingTerm = expressionSide == @"left" ? elemExp.LeftTerm : elemExp.RightTerm;

            (Type type, object obj) val = (null, null);
            switch (workingTerm.TermType)
            {
                case TermType.Constant:
                    {
                        val = (workingTerm.DataType, workingTerm.Value);
                        break;
                    }

                case TermType.Field:
                    {
                        //Get field info
                        (string datasetName, string fieldName) fieldInfo = ExtractFieldData(workingTerm.Value.ToString(), datasets);

                        var dataset = datasets[fieldInfo.datasetName];

                        if (datasetIndex == (dataset.Count - 1))
                        {
                            endofDataset = true;
                        }

                        val = (GetFieldType(dataset[datasetIndex][fieldInfo.fieldName], fieldInfo.datasetName, fieldInfo.fieldName, datasetTypes), dataset[datasetIndex][fieldInfo.fieldName]);
                        break;
                    }

                case TermType.Keyword:
                    {
                        Keyword keyword;
                        if (Enum.TryParse<Keyword>(workingTerm.Value.ToString(), true, out keyword))
                        {
                            switch (keyword)
                            {
                                case Keyword.Null:
                                    {
                                        val = (expressionTerms["left"].type, null);
                                        break;
                                    }
                                case Keyword.User:
                                    {
                                        val = (typeof(string), _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString());
                                        break;
                                    }
                            }
                        }

                        else
                        {
                            throw new ArgumentOutOfRangeException(workingTerm.Value.ToString(), string.Format(@"{0} is not a valid Keyword", workingTerm.Value.ToString()));
                        }
                        break;
                    }

                case TermType.FieldFunc:
                    {
                        //Get field info
                        (string datasetName, string fieldName) fieldInfo = ExtractFieldData(workingTerm.FieldFuncTerm.Value.ToString(), datasets);

                        var dataset = datasets[fieldInfo.datasetName];

                        //Evaluate based on FieldFunction
                        switch (workingTerm.FieldFunction)
                        {
                            case FieldFunction.Count:
                                {
                                    val = (typeof(double), dataset.Where(x => x[fieldInfo.fieldName] != null).Count());
                                    break;
                                }

                            case FieldFunction.Sum:
                                {
                                    //Check if the field's actually summable (i.e., double type)
                                    Type innerType = GetFieldType(dataset[0][fieldInfo.fieldName], fieldInfo.datasetName, fieldInfo.fieldName, datasetTypes);
                                    if (innerType != typeof(double))
                                    {
                                        throw new ArgumentOutOfRangeException(fieldInfo.fieldName, string.Format(@"{0} cannot be used in a sum field function as it is not a numeric type", fieldInfo.fieldName));
                                    }

                                    val = (typeof(double), dataset.Where(x => x[fieldInfo.fieldName] != null).Select(x => Convert.ToDouble(x)).Sum());
                                    break;
                                }

                            default:
                                {
                                    throw new NotImplementedException(string.Format(@"{0} Field Function is not currently implemented", workingTerm.FieldFunction.ToString()));
                                }
                        }

                        break;
                    }

            }

            expressionTerms[expressionSide] = val;
        }

        //Check that right = left from a typing perspective
        if (expressionTerms["left"].type != expressionTerms["right"].type)
        {
            throw new Exception(string.Format(@"For Elementary Expression ""{0}"", Left Term (Type {1}) is not of the same type as Right Term (Type {2}). Elementary expression cannot be evaluated", elemExp.ExpressionText, expressionTerms["left"].type, expressionTerms["right"].type));
        }

        //Check that if ComparisonOperator is >=, <=, >, or < that right/left are of double or datetime type
        if ((elemExp.ComparisonOperator == ComparisonOperator.GreaterThan || elemExp.ComparisonOperator == ComparisonOperator.GreaterThanEquals || elemExp.ComparisonOperator == ComparisonOperator.LessThan || elemExp.ComparisonOperator == ComparisonOperator.LessThanEquals) && expressionTerms["left"].type != typeof(double) && expressionTerms["left"].type != typeof(DateTime) && expressionTerms["right"].type != typeof(double) && expressionTerms["right"].type != typeof(DateTime))
        {
            throw new Exception(string.Format(@"For Elementary Expression ""{0}"", Left Term (Type {1}) and Right Term (Type {2}) cannot be compared with greater/less than operators as they are not both of numeric or date types. Elementary expression cannot be evaluated", elemExp.ExpressionText, expressionTerms["left"].type, expressionTerms["right"].type));

        }

        //Get double/datetime casts if applicable
        double leftDouble = 0;
        double rightDouble = 0;
        DateTime leftDt = DateTime.MinValue;
        DateTime rightDt = DateTime.MinValue;

        bool useDouble = false;
        bool useDateTime = false;

        if (expressionTerms["left"].type == typeof(double))
        {
            leftDouble = Convert.ToDouble(expressionTerms["left"].obj);
            rightDouble = Convert.ToDouble(expressionTerms["right"].obj);

            useDouble = true;
        }

        else if (expressionTerms["left"].type == typeof(DateTime))
        {
            leftDt = Convert.ToDateTime(expressionTerms["left"].obj);
            rightDt = Convert.ToDateTime(expressionTerms["right"].obj);

            useDateTime = true;
        }

        //Evaluate based on ComparisonOperator
        switch (elemExp.ComparisonOperator)
        {
            case ComparisonOperator.Equals:
                {
                    if (useDouble)
                    {
                        return (leftDouble == rightDouble, endofDataset);
                    }

                    else if (useDateTime)
                    {
                        return (leftDt == rightDt, endofDataset);
                    }

                    else
                    {
                        return (expressionTerms["left"].obj.Equals(expressionTerms["right"].obj), endofDataset);
                    }
                }

            case ComparisonOperator.NotEquals:
                {
                    if (useDouble)
                    {
                        return (leftDouble != rightDouble, endofDataset);
                    }

                    else if (useDateTime)
                    {
                        return (leftDt != rightDt, endofDataset);
                    }

                    else
                    {
                        return (!expressionTerms["left"].obj.Equals(expressionTerms["right"].obj), endofDataset);
                    }
                }

            case ComparisonOperator.GreaterThanEquals:
                {

                    if (useDouble)
                    {
                        return (leftDouble >= rightDouble, endofDataset);
                    }

                    else if (useDateTime)
                    {
                        return (leftDt >= rightDt, endofDataset);
                    }

                    throw new Exception(@"Unknown type for comparison");
                }

            case ComparisonOperator.GreaterThan:
                {

                    if (useDouble)
                    {
                        return (leftDouble > rightDouble, endofDataset);
                    }

                    else if (useDateTime)
                    {
                        return (leftDt > rightDt, endofDataset);
                    }

                    throw new Exception(@"Unknown type for comparison");
                }

            case ComparisonOperator.LessThan:
                {

                    if (useDouble)
                    {
                        return (leftDouble < rightDouble, endofDataset);
                    }

                    else if (useDateTime)
                    {
                        return (leftDt < rightDt, endofDataset);
                    }

                    throw new Exception(@"Unknown type for comparison");
                }

            case ComparisonOperator.LessThanEquals:
                {

                    if (useDouble)
                    {
                        return (leftDouble <= rightDouble, endofDataset);
                    }

                    else if (useDateTime)
                    {
                        return (leftDt <= rightDt, endofDataset);
                    }

                    throw new Exception(@"Unknown type for comparison");
                }

            default:
                {
                    throw new Exception(@"Unknown ComparisonOperator");
                }
        }

    }

    private (string workingExpressionStr, Dictionary<string, ElementaryExpression> elemExps) ExtractDatasetFunctions(string workingExpressionStr, Dictionary<string, ElementaryExpression> elemExps)
    {
        string pattern = string.Format(@"({0})\(", string.Join("|", Enum.GetNames(typeof(DatasetFunction))));

        int counter = 1;
        while (Regex.IsMatch(workingExpressionStr, pattern, RegexOptions.IgnoreCase))
        {
            Match match = Regex.Match(workingExpressionStr, pattern, RegexOptions.IgnoreCase);

            int index = match.Index;

            char c = workingExpressionStr[index];

            //Move inboard from function to first open bracket
            while (c != '(')
            {
                index++;
                c = workingExpressionStr[index];
            }

            int startIndex = index;

            //Proceed until open bracket count = closed bracket count
            int openBracketCount = 1;
            int closeBracketCount = 0;

            while (openBracketCount != closeBracketCount)
            {
                index++;
                c = workingExpressionStr[index];

                if (c == '(')
                {
                    openBracketCount++;
                }

                else if (c == ')')
                {
                    closeBracketCount++;
                }
            }

            DatasetFunction dsFunction;
            if (Enum.TryParse<DatasetFunction>(match.Value.Substring(0, match.Value.Length - 1), true, out dsFunction))
            {
                //Get extract
                string extract = workingExpressionStr.Substring(startIndex + 1, index - startIndex - 1);

                //Check extract elementary expressions to ensure if they contain fields and that they're all from the same dataset
                MatchCollection elemMatches = Regex.Matches(extract, @"\@E[0-9]+\@");

                List<string> functionDatasets = new List<string>();
                foreach (Match elemMatch in elemMatches)
                {
                    if (!elemExps.ContainsKey(elemMatch.Value))
                    {
                        throw new Exception($"Elementary Expression collection does not contain {elemMatch.Value} placeholder");
                    }

                    ElementaryExpression workingElem = elemExps[elemMatch.Value];

                    if (workingElem.LeftTerm.TermType != TermType.Field && workingElem.RightTerm.TermType != TermType.Field)
                    {
                        throw new Exception($"Dataset Functions can only contain Elementary Expressions that have a Field Term. Elementary Expression \"{workingElem.ExpressionText}\" does not have a Field Term");
                    }

                    else if (workingElem.LeftTerm.TermType == TermType.Field)
                    {
                        string dsExtract = Regex.Match(@"(?<=\[)[^\]\[]+(?=\]\.)", workingElem.LeftTerm.Value.ToString()).Value;

                        if (!functionDatasets.Contains(dsExtract) && functionDatasets.Count == 1)
                        {
                            throw new Exception($"The Left Term of Elementary Expression \"{workingElem.ExpressionText}\" contains a Dataset ({dsExtract}) that does not align with the rest of the Dataset Function. All Field Terms in all Elementary Expressions in a Dataset Function must be of the same Dataset");
                        }

                        else if (!functionDatasets.Contains(dsExtract))
                        {
                            functionDatasets.Add(dsExtract);
                        }
                    }

                    else if (workingElem.RightTerm.TermType == TermType.Field)
                    {
                        string dsExtract = Regex.Match(@"(?<=\[)[^\]\[]+(?=\]\.)", workingElem.RightTerm.Value.ToString()).Value;

                        if (!functionDatasets.Contains(dsExtract) && functionDatasets.Count == 1)
                        {
                            throw new Exception($"The Right Term of Elementary Expression \"{workingElem.ExpressionText}\" contains a Dataset ({dsExtract}) that does not align with the rest of the Dataset Function. All Field Terms in all Elementary Expressions in a Dataset Function must be of the same Dataset");
                        }

                        else if (!functionDatasets.Contains(dsExtract))
                        {
                            functionDatasets.Add(dsExtract);
                        }
                    }

                    workingElem.DatasetFunction = dsFunction;
                }

                //Replace Dataset function in workingExpressionStr
                workingExpressionStr = workingExpressionStr.Replace(workingExpressionStr.Substring(match.Index, index - match.Index + 1), workingExpressionStr.Substring(startIndex, index - startIndex + 1));

            }

            else
            {
                throw new Exception($"Unable to extract valid Dataset Function from {workingExpressionStr}");
            }
        }

        return (workingExpressionStr, elemExps);
    }

    private (string datasetName, string fieldName) ExtractFieldData(string fullFieldName, Dictionary<string, List<Dictionary<string, object>>> datasets)
    {
        if (datasets == null)
        {
            throw new ArgumentNullException(@"datasets", @"datasets cannot be null as Expression contains Field-type Terms");
        }

        string datasetName = Regex.Match(fullFieldName, @"(?<=\[)[^\]]+(?=\]\.)").Value;

        if (!datasets.ContainsKey(datasetName))
        {
            throw new ArgumentOutOfRangeException(datasetName, string.Format(@"{0} is not an existing datasets in the provided datasets object", datasetName));
        }

        var dataset = datasets[datasetName];

        string fieldName = Regex.Match(fullFieldName, @"(?<=\.\[)[^\]]+(?=\])").Value;

        if (!dataset[0].ContainsKey(fieldName))
        {
            throw new ArgumentOutOfRangeException(fieldName, string.Format(@"{0} does not exist in Dataset {1}", fieldName, datasetName));
        }

        return (datasetName, fieldName);

    }

    private Type GetFieldType(object obj, string datasetName, string fieldName, Dictionary<string, Dictionary<string, Type>> datasetTypes)
    {
        if (datasetTypes != null)
        {
            if (datasetTypes.ContainsKey(datasetName))
            {
                if (datasetTypes[datasetName].ContainsKey(fieldName))
                {
                    return datasetTypes[datasetName][fieldName];
                }
            }

        }

        return Term.GetTermType(obj).type;
    }

    private string RemoveSuperfluousBrackets(string workingExpressionStr)
    {
        //Remove superfluous brackets which are any brackets over DS/E expressions with no logical operators
        while (Regex.IsMatch(workingExpressionStr, @"\([^\&\|\(\)]+\)"))
        {
            string val = Regex.Match(workingExpressionStr, @"\([^\&\|\(\)]+\)").Value;
            string newVal = Regex.Match(val, @"(?<=\()[^\(\)]+(?=\))").Value;

            workingExpressionStr = workingExpressionStr.Replace(val, newVal);
        }

        //Remove any brackets with nothing in them
        while (Regex.IsMatch(workingExpressionStr, @"\(\)"))
        {
            string val = Regex.Match(workingExpressionStr, @"\(\)").Value;

            workingExpressionStr = workingExpressionStr.Replace(val, string.Empty);
        }

        BracketCheck(workingExpressionStr);

        return workingExpressionStr;
    }

    private void BracketCheck(string workingExpressionStr, char bracket = '(')
    {
        char closeBracket = '\0';
        if (bracket == '(')
        {
            closeBracket = ')';
        }

        else if (bracket == '[')
        {
            closeBracket = ']';
        }

        if (closeBracket == '\0')
        {
            throw new ArgumentOutOfRangeException(@"bracket", $"Cannot perform a bracket check on {bracket} character");
        }

        //Check for bracket equality
        int index = 0;
        int openBracketCount = 0;
        while (index < workingExpressionStr.Length)
        {
            char c = workingExpressionStr[index];

            if (c == bracket)
            {
                openBracketCount++;
            }

            else if (c == closeBracket)
            {
                openBracketCount--;
            }

            if (openBracketCount < 0)
            {
                throw new Exception($"There are some unclosed \"{bracket}{closeBracket}\" brackets in the provided expression");
            }

            index++;
        }

        if (openBracketCount > 0)
        {
            throw new Exception($"There are some unclosed \"{bracket}{closeBracket}\" brackets in the provided expression");
        }
    }

}
