using System;
using System.Text.RegularExpressions;

namespace StingrayNET.ApplicationCore.Models.ExpressionSerializer
{
    public enum TermType
    {
        Constant = 1,
        Field = 2,
        FieldFunc = 3,
        Keyword = 4
    }

    public enum TermDatePart
    {
        Year = 1,
        Month = 2,
        Day = 3
    }

    public enum Keyword
    {
        Null = 1,
        User = 2
    };

    public enum FieldFunction
    {
        Count = 1,
        Sum = 2,
        Max = 3,
        Min = 4
    };

    public class Term
    {
        public TermType TermType { get; private set; }
        public object Value { get; private set; }
        public Term? FieldFuncTerm { get; private set; }
        public Type? DataType { get; private set; }
        public FieldFunction? FieldFunction { get; private set; }

        public Term(TermType termType, object value, bool forceStringType = false, Term? fieldFuncTerm = null, FieldFunction? fieldFunction = null)
        {
            TermType = termType;
            Value = value;

            string valueAsStr = Value.ToString();
            double doubleTryParse;
            if (TermType == TermType.Constant)
            {
                var termTypeConvert = GetTermType(value, forceStringType);

                Value = termTypeConvert.obj;
                DataType = termTypeConvert.type;
            }

            else if (TermType == TermType.FieldFunc)
            {
                if (fieldFuncTerm != null)
                {
                    FieldFuncTerm = fieldFuncTerm;
                }

                else
                {
                    //Extract content from within parentheses
                    if (!Regex.IsMatch(valueAsStr, @"(?<=\()[^\(\)]+(?=\))"))
                    {
                        throw new ArgumentOutOfRangeException(@"value", string.Format(@"Field Function term does not contain a valid Field-type term within parentheses. Expected format is ([DatasetName].[FieldName])"));
                    }

                    FieldFuncTerm = new Term(TermType.Field, Regex.Match(valueAsStr, @"(?<=\()[^\(\)]+(?=\))").Value);
                }

                if (fieldFunction != null)
                {
                    FieldFunction = fieldFunction;
                }

                else
                {
                    //Extract field function
                    if (!Regex.IsMatch(valueAsStr, $"^{string.Join("|", Enum.GetNames(typeof(FieldFunction)))}", RegexOptions.IgnoreCase))
                    {
                        throw new ArgumentOutOfRangeException(@"value", string.Format(@"Field Function term does not contain a valid Field-type term within parentheses. Valid function names are {0}", string.Join("|", Enum.GetNames(typeof(FieldFunction)))));
                    }

                    FieldFunction parseFieldFunction;
                    if (Enum.TryParse<FieldFunction>(Regex.Match(valueAsStr, $"^{string.Join("|", Enum.GetNames(typeof(FieldFunction)))}", RegexOptions.IgnoreCase).Value, true, out parseFieldFunction))
                    {
                        FieldFunction = parseFieldFunction;
                    }
                }

            }

            else if (TermType == TermType.Keyword)
            {
                Keyword keyword;
                if (!Enum.TryParse<Keyword>(valueAsStr, true, out keyword))
                {
                    throw new ArgumentOutOfRangeException(@"value", string.Format(@"{0} is not a valid Keyword", valueAsStr));
                }
            }

            else if (TermType == TermType.Field)
            {
                if (!Regex.IsMatch(valueAsStr, @"\[[^\[\]]+\]\.\[[^\[\]]+\]"))
                {
                    throw new ArgumentOutOfRangeException(@"value", string.Format(@"Field type Term has an invalid format. Expected format was [DatasetName].[FieldName]"));
                }
            }
        }

        private static int ExtractDatePortion(string dtStr, TermDatePart termDatePart)
        {
            string pattern = string.Empty;

            switch (termDatePart)
            {
                case TermDatePart.Year:
                    {
                        pattern = @"(?<=\()[0-9]+(?=\,)";
                        break;
                    }

                case TermDatePart.Month:
                    {
                        pattern = @"(?<=\,)[0-9]+(?=\,)";
                        break;
                    }

                case TermDatePart.Day:
                    {
                        pattern = @"(?<=\,)[0-9]+(?=\))";
                        break;
                    }

            }

            //Extract pieces of the date
            if (Regex.IsMatch(dtStr, pattern) && !string.IsNullOrEmpty(pattern))
            {
                return Convert.ToInt32(Regex.Match(dtStr, pattern).Value);
            }

            else
            {
                throw new ArgumentOutOfRangeException(@"dtStr", string.Format(@"dt arguments out of order or improperly formatted. Should be in (yyyy,mm,dd) format"));
            }
        }

        public static (Type type, object obj) GetTermType(object value, bool forceStringType = false)
        {
            string valueAsStr = value.ToString();

            object workingObj = null;
            Type workingType = null;

            double doubleTryParse;
            if (forceStringType)
            {
                workingObj = valueAsStr;
                workingType = typeof(string);
            }

            else if (Regex.IsMatch(valueAsStr, @"^dt"))
            {
                int year = ExtractDatePortion(valueAsStr, TermDatePart.Year);
                int mth = ExtractDatePortion(valueAsStr, TermDatePart.Month);
                int day = ExtractDatePortion(valueAsStr, TermDatePart.Day);

                workingObj = new DateTime(year, mth, day);
                workingType = typeof(DateTime);
            }

            else if (valueAsStr.ToLower() == "true" || valueAsStr.ToLower() == "false")
            {
                workingType = typeof(bool);
                workingObj = Convert.ToBoolean(valueAsStr);
            }

            else if (double.TryParse(valueAsStr, out doubleTryParse))
            {
                workingType = typeof(double);
                workingObj = doubleTryParse;
            }

            else
            {
                workingType = typeof(string);
                workingObj = valueAsStr;
            }

            if (workingObj == null || workingType == null)
            {
                throw new Exception(string.Format(@"Unable to extract the term type for {0}", valueAsStr));
            }

            return (workingType, workingObj);

        }

        public string GetTermText()
        {
            switch (TermType)
            {
                case TermType.Constant:
                    {
                        if (DataType == typeof(DateTime))
                        {
                            DateTime dtValue = Convert.ToDateTime(Value);

                            return $"dt({dtValue.Year},{dtValue.Month},{dtValue.Day})";
                        }

                        else
                        {
                            return Value.ToString();
                        }
                    }

                case TermType.FieldFunc:
                    {
                        return $"{FieldFunction.ToString()}({FieldFuncTerm.Value.ToString()})";
                    }

                default:
                    {
                        return Value.ToString();
                    }

            }
        }

    }
}
