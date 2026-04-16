using System;
using System.Text.RegularExpressions;

namespace StingrayNET.ApplicationCore.Models.ExpressionSerializer
{
    public class ElementaryExpression
    {
        public Term LeftTerm { get; private set; }
        public Term RightTerm { get; private set; }
        public ComparisonOperator ComparisonOperator { get; private set; }
        public string ExpressionText { get; private set; }
        public DatasetFunction? DatasetFunction { get; set; } = null;

        public ElementaryExpression(Term leftTerm,
            ComparisonOperator comparisonOperator,
            Term rightTerm)
        {
            //Null checks for LeftTerm, RightTerm, and ComparisonOperator
            if (leftTerm == null || rightTerm == null || comparisonOperator == null)
            {
                throw new ArgumentException(@"leftTerm, rightTerm, and comparisonOperator all must be non-null for an Elementary-type expression");
            }

            //If one of the terms if a Field Function, its counterpart should be a number constant or Field
            Term fieldFuncTerm = null;
            string fieldFuncTermSide = null;
            bool fieldFuncEquivalency = true;

            if (leftTerm.TermType == TermType.FieldFunc)
            {
                if (!((rightTerm.TermType == TermType.Constant && rightTerm.DataType == typeof(double)) || (rightTerm.TermType == TermType.Field)))
                {
                    fieldFuncEquivalency = false;
                }
            }
            else if (leftTerm.TermType == TermType.FieldFunc)
            {
                if (!((leftTerm.TermType == TermType.Constant && leftTerm.DataType == typeof(double)) || (leftTerm.TermType == TermType.Field)))
                {
                    fieldFuncEquivalency = false;
                }
            }

            if (!fieldFuncEquivalency)
            {
                throw new ArgumentException(@"A number-type Constant term or Field-type term must be the counterpart to a Field Function-type term in an elementary expression");
            }

            LeftTerm = leftTerm;
            RightTerm = rightTerm;
            ComparisonOperator = comparisonOperator;

            ExpressionText = $"{LeftTerm.GetTermText()} {GetComparisonOperatorText(ComparisonOperator)} {RightTerm.GetTermText()}";
        }

        public static string GetComparisonOperatorText(ComparisonOperator comparisonOperator)
        {

            if (comparisonOperator == ComparisonOperator.GreaterThan)
            {
                return @">";
            }

            else if (comparisonOperator == ComparisonOperator.LessThan)
            {
                return @"<";
            }

            else if (comparisonOperator == ComparisonOperator.Equals)
            {
                return @"=";
            }

            else if (comparisonOperator == ComparisonOperator.GreaterThanEquals)
            {
                return @">=";
            }

            else if (comparisonOperator == ComparisonOperator.LessThanEquals)
            {
                return @"<=";
            }


            else if (comparisonOperator == ComparisonOperator.NotEquals)
            {
                return @"<>";
            }

            else
            {
                throw new ArgumentOutOfRangeException(@"elemExpStr", string.Format(@"Failed to obtain comparison operator text from {0}", comparisonOperator.ToString()));

            }

        }

        public static ComparisonOperator GetComparisonOperator(string elemExpStr)
        {

            if (Regex.IsMatch(elemExpStr, @"(?<=\s)\>(?=\s)"))
            {
                return ComparisonOperator.GreaterThan;
            }

            else if (Regex.IsMatch(elemExpStr, @"(?<=\s)\<(?=\s)"))
            {
                return ComparisonOperator.LessThan;
            }

            else if (Regex.IsMatch(elemExpStr, @"(?<=\s)\=(?=\s)"))
            {
                return ComparisonOperator.Equals;
            }

            else if (Regex.IsMatch(elemExpStr, @"(?<=\s)\>\=(?=\s)"))
            {
                return ComparisonOperator.GreaterThanEquals;
            }

            else if (Regex.IsMatch(elemExpStr, @"(?<=\s)\<\=(?=\s)"))
            {
                return ComparisonOperator.LessThanEquals;
            }


            else if (Regex.IsMatch(elemExpStr, @"(?<=\s)((\<\>)|(\!\=))(?=\s)"))
            {
                return ComparisonOperator.NotEquals;
            }

            else
            {
                throw new ArgumentOutOfRangeException(@"elemExpStr", string.Format(@"Failed to obtain comparison operator from ""{0}"". Ensure there are spaces between the terms and the operator", Regex.Match(elemExpStr, @"[\>\<|\=|\!]+").Value));

            }

        }

    }
}
