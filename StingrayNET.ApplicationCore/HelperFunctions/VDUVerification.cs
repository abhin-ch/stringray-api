using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Data;

// namespace DEMSLib
namespace StingrayNET.ApplicationCore.HelperFunctions
{
    public static class VDUVerification
    {
        public enum TextAllowedValue
        {
            A_AllowEverything = 0,
            B_AlphaNumeric = 1,
            C_AlphaNumericNoSpace = 2,
            D_Alpha = 3,
            E_AlphaNoSpace = 4,
            F_Integer = 5,
            G_Decimal = 6,
            H_UseCustomRegEx = 7,
            I_Number = 8,
            J_AlphaNumericUnderscoreAndHypen = 9,
            K_AlphaNumericUnderscoreAndHypenNoSpace = 10,
            L_DateTime = 11,
            M_AlphaNumericAndSomeOtherSafeCharacters = 12,
            O_WebURI = 13,
            P_Email = 14,
            Q_DateAsyyyyMMDD = 15,
            R_BeforeDate = 16,
            S_OnOrAfterDate = 17,
            T_GreaterThan = 18,
            U_GreaterThanOrEqual = 19,
            V_LessThan = 20,
            W_LessThanOrEqual = 21,
            X_Equals = 22,
            Y_NotEquals = 23,
            Z_Bool = 24,
            AA_Unique = 25,
            AB_NotNull = 26,
            AC_InProvidedList = 27,
            AD_UseCustomMultiField = 28,
            AE_InPipeSeparatedList = 29,
            AF_MaximumLength = 30,
        }

        public static bool IsMyValueEmpty(object myValueToCheck)
        {
            bool myReturnValue = false;
            if (myValueToCheck == null)
                return true;
            else if (myValueToCheck == DBNull.Value)
                return true;
            else if (myValueToCheck.ToString() == "")
                return true;
            else if (myValueToCheck.ToString().Trim().ToString().Length == 0)
                return true;

            return myReturnValue;
        }

        public static object IsMyValueEmptyReturn(object myValueToCheck, object myReturnIfNone)
        {
            if (myValueToCheck == null)
                return myReturnIfNone;
            else if (myValueToCheck == DBNull.Value)
                return myReturnIfNone;
            else if (myValueToCheck.ToString() == "")
                return myReturnIfNone;
            else if (myValueToCheck.ToString().Trim().ToString().Length == 0)
                return myReturnIfNone;

            return myValueToCheck;
        }

        /// <summary>
        ///         ''' 
        ///         ''' </summary>
        ///         ''' <param name="myValueToCheck">Value to check, retrieved from the database</param>
        ///         ''' <param name="myNewValueIfNull">The value to get if [myValueToCheck] Is Null</param>
        ///         ''' <returns>[myNewValueIfNull] if [myValueToCheck] Is Null, Else [myValueToCheck]</returns>
        ///         ''' <remarks></remarks>
        public static object nZ(object myValueToCheck, object myNewValueIfNull)
        {
            if (IsMyValueEmpty(myValueToCheck) == true)
                return myNewValueIfNull;
            else
                return myValueToCheck;
        }

        /// <summary>
        /// Checks whether a string meets defined rule criteria
        /// </summary>
        /// <param name="myTextAllowed">Enum value for the rule being checked</param>
        /// <param name="myTextToCheck">String being checked</param>
        /// <param name="myRuleValue">String value for some options - e.g. date comparisons, custom regex, etc</param>
        /// <param name="myRuleList">List of strings for some options - e.g. AC_InProvidedList</param>
        /// <returns>Boolean - is it valid</returns>
        public static bool IsMyPassedTextValid(TextAllowedValue myTextAllowed, string myTextToCheck, string myRuleValue = "", List<string> myRuleList = null)
        {
            switch (myTextAllowed)
            {
                case TextAllowedValue.A_AllowEverything:
                    {
                        return true;
                    }

                case TextAllowedValue.B_AlphaNumeric:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[0-9a-zA-Z\s]+$");
                    }

                case TextAllowedValue.C_AlphaNumericNoSpace:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[0-9a-zA-Z]+$");
                    }

                case TextAllowedValue.D_Alpha:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[a-zA-Z\s]+$");
                    }

                case TextAllowedValue.E_AlphaNoSpace:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[a-zA-Z]+$");
                    }

                case TextAllowedValue.F_Integer:
                    {
                        int myInteger;
                        if (int.TryParse(myTextToCheck, out myInteger) == true)
                            return true;
                        else
                            return false;
                    }

                case TextAllowedValue.G_Decimal:
                    {
                        decimal myDecimal;
                        if (decimal.TryParse(myTextToCheck, out myDecimal) == true)
                            return true;
                        else
                            return false;
                    }

                case TextAllowedValue.H_UseCustomRegEx:
                    {
                        return Regex.IsMatch(myTextToCheck, myRuleValue);
                    }

                case TextAllowedValue.I_Number:
                    {
                        double myNumber;
                        if (double.TryParse(myTextToCheck, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out myNumber) == true)
                            return true;
                        else
                            return false;
                    }

                case TextAllowedValue.J_AlphaNumericUnderscoreAndHypen:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[0-9a-zA-Z\s_-]+$");
                    }

                case TextAllowedValue.K_AlphaNumericUnderscoreAndHypenNoSpace:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[0-9a-zA-Z_-]+$");
                    }

                case TextAllowedValue.L_DateTime:
                    {
                        DateTime myDate;
                        if (DateTime.TryParse(myTextToCheck, out myDate) == true)
                            return true;
                        if (double.TryParse(myTextToCheck, out double myDbl) == true)
                            try
                            {
                                myDate = DateTime.FromOADate(myDbl);
                                return true;
                            }
                            catch
                            {
                                return false;
                            }
                        else
                            return false;
                    }

                case TextAllowedValue.M_AlphaNumericAndSomeOtherSafeCharacters:
                    {
                        return Regex.IsMatch(myTextToCheck, @"^[0-9a-zA-Z\s.()_,:;-]+$");
                    }

                case TextAllowedValue.O_WebURI:
                    {
                        return Uri.IsWellFormedUriString(myTextToCheck, UriKind.Absolute);
                    }

                case TextAllowedValue.P_Email:
                    {
                        return Regex.IsMatch(myTextToCheck, @"\A[!#$%&'*+/0-9=?_`a-z{|}~^-]+(?:\.[!#$%&'*+/0-9=?_`a-z{|}~^-]+)*@(?:[0-9a-z-]+\.)+[a-z]{2,6}\z");
                    }

                case TextAllowedValue.Q_DateAsyyyyMMDD:
                    {
                        DateTime dt;
                        string[] formats = { "yyyyMMdd" };
                        if (!DateTime.TryParseExact(myTextToCheck, formats,
                                        CultureInfo.InvariantCulture,
                                        DateTimeStyles.None, out dt))
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.R_BeforeDate:
                    {
                        if (DateTime.TryParse(myTextToCheck, out DateTime outTextDt) == false)
                            return false;
                        if (DateTime.TryParse(myRuleValue, out DateTime outRuleDt) == false)
                            return false;
                        if (DateTime.Compare(outTextDt, outRuleDt) >= 0)
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.S_OnOrAfterDate:
                    {
                        if (DateTime.TryParse(myTextToCheck, out DateTime outTextDt) == false)
                            return false;
                        if (DateTime.TryParse(myRuleValue, out DateTime outRuleDt) == false)
                            return false;
                        if (DateTime.Compare(outTextDt, outRuleDt) < 0)
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.T_GreaterThan:
                    {
                        if (decimal.TryParse(myTextToCheck, out decimal outTextDec) == false)
                            return false;
                        if (decimal.TryParse(myRuleValue, out decimal outRuleDec) == false)
                            return false;
                        if (outTextDec <= outRuleDec)
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.U_GreaterThanOrEqual:
                    {
                        if (decimal.TryParse(myTextToCheck, out decimal outTextDec) == false)
                            return false;
                        if (decimal.TryParse(myRuleValue, out decimal outRuleDec) == false)
                            return false;
                        if (outTextDec < outRuleDec)
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.V_LessThan:
                    {
                        if (decimal.TryParse(myTextToCheck, out decimal outTextDec) == false)
                            return false;
                        if (decimal.TryParse(myRuleValue, out decimal outRuleDec) == false)
                            return false;
                        if (outTextDec >= outRuleDec)
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.W_LessThanOrEqual:
                    {
                        if (decimal.TryParse(myTextToCheck, out decimal outTextDec) == false)
                            return false;
                        if (decimal.TryParse(myRuleValue, out decimal outRuleDec) == false)
                            return false;
                        if (outTextDec > outRuleDec)
                            return false;
                        else
                            return true;
                    }
                case TextAllowedValue.X_Equals:
                    {
                        if (myTextToCheck?.ToLower() == myRuleValue?.ToLower())
                            return true;
                        else
                            return false;
                    }
                case TextAllowedValue.Y_NotEquals:
                    {
                        if (myTextToCheck?.ToLower() != myRuleValue?.ToLower())
                            return true;
                        else
                            return false;
                    }
                case TextAllowedValue.Z_Bool:
                    {
                        if (bool.TryParse(myTextToCheck, out bool outBool) == true)
                            return true;
                        else
                            return false;
                    }
                case TextAllowedValue.AA_Unique:
                    {
                        return true; //for single values, always true
                    }
                case TextAllowedValue.AB_NotNull:
                    {
                        return !IsMyValueEmpty(myTextToCheck);
                    }
                case TextAllowedValue.AC_InProvidedList:
                    {
                        //Check against passed list
                        if (myRuleList != null)
                            return myRuleList.Contains(myTextToCheck, StringComparer.CurrentCultureIgnoreCase);
                        else
                            return false;
                    }
                case TextAllowedValue.AD_UseCustomMultiField:
                    {
                        return true; //for single values, always true
                    }
                case TextAllowedValue.AE_InPipeSeparatedList:
                    {
                        //Split string passed by pipe, then trim
                        List<string> myList = myRuleValue.Split('|').Select(p => p.Trim()).ToList();
                        return myList.Contains(myTextToCheck, StringComparer.CurrentCultureIgnoreCase);
                    }
                case TextAllowedValue.AF_MaximumLength:
                    {
                        //If rule value is not an integer, or string length is greater than length, return false
                        if (!int.TryParse(myRuleValue, out int myRuleLength) || myTextToCheck.Length > myRuleLength)
                            return false;

                        return true;
                    }
                default:
                    {
                        return false;
                    }
            }
        }

        /// <summary>
        /// Return messages for each validation enum type
        /// </summary>
        /// <param name="myTextAllowed">Enum value</param>
        /// <param name="myCustomRegExMessage">Custom message for a particular regex check</param>
        /// <param name="myRuleValue">String rule value used if applicable</param>
        /// <param name="myRuleList">List of strings used if applicable</param>
        /// <returns>Error message</returns>
        public static string MyPassedTextValidMessage(TextAllowedValue myTextAllowed, string myCustomRegExMessage, string myRuleValue = "", List<string> myRuleList = null)
        {
            switch (myTextAllowed)
            {
                case TextAllowedValue.B_AlphaNumeric:
                    {
                        return "Only Alphanumeric characters are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.C_AlphaNumericNoSpace:
                    {
                        return "Only Alphanumeric characters with no spaces are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.D_Alpha:
                    {
                        return "Only Alpha characters are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.E_AlphaNoSpace:
                    {
                        return "Only Alpha characters with no spaces are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.F_Integer:
                    {
                        return "Only Integers e.g. 1, 2, 3, 4 are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.G_Decimal:
                    {
                        return "Only Decimals e.g. 1.1, 2.5, 3.8, 4.56 are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.H_UseCustomRegEx:
                    {
                        return myCustomRegExMessage;
                    }

                case TextAllowedValue.I_Number:
                    {
                        return "Only numbers are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.J_AlphaNumericUnderscoreAndHypen:
                    {
                        return "Only Alphanumeric, space, underscore and hyphen characters are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.K_AlphaNumericUnderscoreAndHypenNoSpace:
                    {
                        return @"Only Alphanumeric, underscore and hyphen characters are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.L_DateTime:
                    {
                        return "Only valid date and time are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.M_AlphaNumericAndSomeOtherSafeCharacters:
                    {
                        return "Only Alphanumeric and () - , . : ; _ characters are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.O_WebURI:
                    {
                        return "Only valid Web links are allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.P_Email:
                    {
                        return "Only valid Email is allowed. Please correct and try again. Thank you";
                    }

                case TextAllowedValue.Q_DateAsyyyyMMDD:
                    {
                        return "Only valid date is allowed. Please correct and try again. Thank you";
                    }
                case TextAllowedValue.R_BeforeDate:
                    {
                        return string.Format("Only dates before {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.S_OnOrAfterDate:
                    {
                        return string.Format("Only dates on or after {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.T_GreaterThan:
                    {
                        return string.Format("Only numbers greater than {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.U_GreaterThanOrEqual:
                    {
                        return string.Format("Only numbers greater than or equal to {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.V_LessThan:
                    {
                        return string.Format("Only numbers less than {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.W_LessThanOrEqual:
                    {
                        return string.Format("Only numbers less than or equal to {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.X_Equals:
                    {
                        return string.Format("Only values equal to {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.Y_NotEquals:
                    {
                        return string.Format("Only values not equal to {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.Z_Bool:
                    {
                        return "Only True/False are allowed. Please correct and try again. Thank you";
                    }
                case TextAllowedValue.AB_NotNull:
                    {
                        return "Only non-blank values are allowed. Please correct and try again. Thank you";
                    }
                case TextAllowedValue.AC_InProvidedList:
                    {
                        return string.Format("Only values in the list {0} are allowed. Please correct and try again. Thank you", string.Join(", ", myRuleList));
                    }
                case TextAllowedValue.AE_InPipeSeparatedList:
                    {
                        return string.Format("Only values in the list {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                case TextAllowedValue.AF_MaximumLength:
                    {
                        return string.Format("Only values of maximum length {0} are allowed. Please correct and try again. Thank you", myRuleValue);
                    }
                default:
                    {
                        return string.Empty;
                    }
            }
        }

        /// <summary>
        /// Applied validation checks to a datatable column
        /// </summary>
        /// <param name="myTextAllowed">Enum value for check</param>
        /// <param name="myDataTable">Datatable being checked</param>
        /// <param name="myColumnName">Column being checked</param>
        /// <param name="myRuleValue">String rule value for applicable checks</param>
        /// <param name="myRuleList">List of strings for applicable checks</param>
        /// <returns>Int array containing row indices with invalid values</returns>
        public static int[] DataTableInvalidIndices(TextAllowedValue myTextAllowed, DataTable myDataTable, string myColumnName, string myRuleValue = "", List<string> myRuleList = null)
        {
            if (!myDataTable.Columns.Contains(myColumnName))
                return new int[0];

            switch (myTextAllowed)
            {
                case TextAllowedValue.A_AllowEverything:
                    {
                        return new int[0];
                    }

                case TextAllowedValue.AA_Unique:
                    {
                        //Return indices as a flat array for any duplicates
                        //NOT grouped by duplicate
                        return myDataTable.AsEnumerable()
                                                       .Select((dr, index) => index)
                                                       .GroupBy(x => myDataTable.Rows[x][myColumnName])
                                                       .Where(g => g.Count() > 1)
                                                       .Select(g => g.ToArray())
                                                       .SelectMany(x => x).ToArray();
                    }

                case TextAllowedValue.AC_InProvidedList:
                    {
                        //If list not provided return empty
                        if (myRuleList != null)
                            return myDataTable.AsEnumerable()
                                        .Select((row, index) => new { row, index })
                                        .Where(item => !myRuleList.Contains(item.row.Field<string>(myColumnName) ?? "", StringComparer.CurrentCultureIgnoreCase))
                                        .Select(item => item.index).ToArray();
                        else
                            return new int[0];
                    }

                case TextAllowedValue.AD_UseCustomMultiField:
                    {
                        List<int> myRowIndices = new List<int>();

                        try
                        {
                            //Try selecting any rows that don't meet the criteria
                            DataRow[] myFailedRows = myDataTable.Select(string.Format("NOT ({0})",myRuleValue));

                            //Add row indices for failed rows
                            foreach(DataRow failedRow in myFailedRows)
                            {
                                myRowIndices.Add(myDataTable.Rows.IndexOf(failedRow));
                            }
                        }
                        catch
                        {
                            //If the multi-field condition is not defined properly, fail all rows
                            for(int i = 0; i < myDataTable.Rows.Count; i++)
                            {
                                myRowIndices.Add(i);
                            }
                        }
                        return myRowIndices.ToArray();
                    }

                case TextAllowedValue.AE_InPipeSeparatedList:
                    {
                        //Use custom override with hashset for efficiency
                        HashSet<string> listHash = new HashSet<string>(myRuleValue.Split('|').Select(p => p.Trim()));
                        return myDataTable.AsEnumerable()
                                            .Select((row, index) => new { row, index })
                                            .Where(item => !listHash.Contains(item.row.Field<string>(myColumnName) ?? "", StringComparer.CurrentCultureIgnoreCase))
                                            .Select(item => item.index).ToArray();
                    }
                default:
                    {
                        List<int> myRowIndices = new List<int>();
                        for (int i = 0; i < myDataTable.Rows.Count; i++)
                        {
                            if (!IsMyPassedTextValid(myTextAllowed,
                                                     myDataTable.Rows[i][myColumnName].ToString(),
                                                     myRuleValue))
                            {
                                myRowIndices.Add(i);
                            }
                        }
                        return myRowIndices.ToArray();
                    }
            }
        }
    }
}