using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    public static class VDSVerification
    {
        //Enum for VDS data dates in database
        public enum DataAsOf
        {
            Sunday = 0,
            Monday = 1,
            Tuesday = 2,
            Wednesday = 3,
            Thursday = 4,
            Friday = 5,
            Saturday = 6,
            AnyDay = 7,
            NotRequired = 8,
        }

        //Rule types for column rules
        public enum RuleType
        {
            Error = 0,
            Warning = 1
        }

        public enum ErrorsFound
        {
            None,
            Errors,
            Warnings,
            ErrorsAndWarnings
        }

        //Check what types of errors are in the list
        public static ErrorsFound ErrorTypesFound(List<VDSReportError> errorList)
        {
            //If resulting errors were error type and not only warnings
            if (errorList.Any(e => e.RuleType == RuleType.Error))
            {
                if (errorList.Any(e => e.RuleType == RuleType.Warning))
                {
                    return ErrorsFound.ErrorsAndWarnings;
                }
                return ErrorsFound.Errors;
            }
            else if (errorList.Any(e => e.RuleType == RuleType.Warning))
            {
                return ErrorsFound.Warnings;
            }
            return ErrorsFound.None;
        }

        //Returns a list of tuples representing the row-column indexes of failed conversions
        //Can run on entire table or particular row
        public static List<Tuple<int, int>> DataTableConversionFailures(DataTable valuesTable, DataTable typesTable, int? rowToCheck = null)
        {
            List<Tuple<int, int>> rowCols = new List<Tuple<int, int>>();

            int[] rowsToCheck = Enumerable.Range(rowToCheck ?? 0, rowToCheck.HasValue ? 1 : valuesTable.Rows.Count).ToArray();

            foreach (int i in rowsToCheck)
            {
                for (int j = 0; j < valuesTable.Columns.Count; j++)
                {
                    //Don't run type checks on null values
                    //If nulls are not allowed, null check will catch it
                    if (!VDUVerification.IsMyValueEmpty(valuesTable.Rows[i][j]))
                    {
                        try
                        {
                            Convert.ChangeType(valuesTable.Rows[i][j], typesTable.Columns[j].DataType);
                        }
                        catch
                        {
                            rowCols.Add(new Tuple<int, int>(i, j));
                        }
                    }
                }
            }
            return rowCols;
        }

        //Returns a list of tuples representing the row-column indexes of invalid nulls
        //Uses the typesTable "AllowsNull" parameter for the check on each column
        //Can run on entire table or particular row
        public static List<Tuple<int, int>> DataTableNullCheck(DataTable valuesTable, DataTable typesTable, int? rowToCheck = null)
        {
            List<Tuple<int, int>> rowCols = new List<Tuple<int, int>>();

            int[] rowsToCheck = Enumerable.Range(rowToCheck ?? 0, rowToCheck.HasValue ? 1 : valuesTable.Rows.Count).ToArray();

            for (int j = 0; j < valuesTable.Columns.Count; j++)
            {
                if (!typesTable.Columns[j].AllowDBNull)
                {
                    foreach (int i in rowsToCheck)
                    {
                        if (VDUVerification.IsMyValueEmpty(valuesTable.Rows[i][j]))
                        {
                            rowCols.Add(new Tuple<int, int>(i, j));
                        }
                    }
                }
            }
            return rowCols;
        }

        //Returns a list of tuples representing the row-column indexes of too-long values
        //Uses the typesTable "MaxLength" property
        //Can run on entire table or particular row
        public static List<Tuple<int, int>> DataTableMaxLengthCheck(DataTable valuesTable, DataTable typesTable, int? rowToCheck = null)
        {
            List<Tuple<int, int>> rowCols = new List<Tuple<int, int>>();

            int[] rowsToCheck = Enumerable.Range(rowToCheck ?? 0, rowToCheck.HasValue ? 1 : valuesTable.Rows.Count).ToArray();

            for (int j = 0; j < valuesTable.Columns.Count; j++)
            {
                int maxLength = typesTable.Columns[j].MaxLength;
                if (maxLength != -1)
                {
                    foreach (int i in rowsToCheck)
                    {
                        if (valuesTable.Rows[i][j].ToString().Length > maxLength)
                        {
                            rowCols.Add(new Tuple<int, int>(i, j));
                        }
                    }
                }
            }
            return rowCols;
        }
    }
}
