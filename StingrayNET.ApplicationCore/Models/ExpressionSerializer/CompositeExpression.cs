using System;
using System.Security.Principal;
using System.Text.RegularExpressions;

namespace StingrayNET.ApplicationCore.Models.ExpressionSerializer
{
    public enum CompositeExpressionTermType
    {
        Elementary = 1,
        DatasetFunction = 2,
        Composite = 3
    }

    public class CompositeExpression
    {
        public string OriginalValue { get; private set; }

        public LogicalOperator LogicalOperator { get; private set; }

        public string LeftTerm { get; private set; }
        public CompositeExpressionTermType LeftTermType { get; private set; }

        public string RightTerm { get; private set; }
        public CompositeExpressionTermType RightTermType { get; private set; }

        public CompositeExpression(string value)
        {
            OriginalValue = value;

            //Get logical operator
            if (Regex.IsMatch(value, @"\||\&"))
            {
                string logOpVal = Regex.Match(value, @"\||\&").Value;

                if (logOpVal == @"&")
                {
                    LogicalOperator = LogicalOperator.AND;
                }

                else
                {
                    LogicalOperator = LogicalOperator.OR;
                }

            }

            else
            {
                throw new ArgumentException($"Unable to extract logical operator from Composite Expression {value}");
            }

            //Get left and right side components
            MatchCollection sides = Regex.Matches(value, @"[@EDSC0-9]+");
            int sideCounter = 0;
            foreach (Match side in sides)
            {
                sideCounter++;

                //Determine if side is a Composite Exp, Elem Exp, or Dataset Function
                CompositeExpressionTermType? workingTermType = null;
                if (side.Value.Contains(@"E"))
                {
                    workingTermType = CompositeExpressionTermType.Elementary;
                }

                else if (side.Value.Contains(@"DS"))
                {
                    workingTermType = CompositeExpressionTermType.DatasetFunction;
                }

                else if (side.Value.Contains(@"C"))
                {
                    workingTermType = CompositeExpressionTermType.Composite;
                }

                else
                {
                    throw new ArgumentException($"{side.Value} is an invalid term for a Composite Expression");
                }

                if (sideCounter == 1)
                {
                    LeftTerm = side.Value;
                    LeftTermType = (CompositeExpressionTermType)workingTermType;
                }

                else if (sideCounter == 2)
                {
                    RightTerm = side.Value;
                    RightTermType = (CompositeExpressionTermType)workingTermType;
                }

            }

            if (sideCounter != 2)
            {
                throw new ArgumentException($"Unable to extract left and right terms of Composite Expression {value}");
            }

        }
    }
}
