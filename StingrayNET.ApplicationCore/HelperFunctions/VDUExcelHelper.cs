using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.HelperFunctions
{
    public static class VDUExcelHelper
    {

        /// <summary>
        /// Returns the specified sheet object from an Excel package. NULL if sheet does not exist
        /// </summary>
        /// <param name="excelPackage">An Excel package (EPPlus) object</param>
        /// <param name="sheetName">The name of the sheet to return</param>
        /// <returns></returns>
        public static ExcelWorksheet GetSheet(ExcelPackage excelPackage, string sheetName)
        {
            return excelPackage.Workbook.Worksheets.FirstOrDefault(x => x.Name == sheetName);
        }

        /// <summary>
        /// Returns the names of all sheet objects from an Excel package
        /// </summary>
        /// <param name="excelPackage">An Excel package (EPPlus) object</param>
        /// <returns></returns>
        public static List<string> GetSheetNames(ExcelPackage excelPackage) 
        {
            List<string> returnList = new List<string>();

            foreach(ExcelWorksheet worksheet in excelPackage.Workbook.Worksheets) 
            {
                returnList.Add(worksheet.Name);
            }

            return returnList;
        }

        /// <summary>
        /// Returns a datatable containing the contents of an excel worksheet
        /// </summary>
        /// <param name="excelWorksheet">An Excel worksheet object</param>
        /// <param name="startRow">Optional start row of the worksheet</param>
        /// <param name="startCol">Optional start column of the worksheet (1-based)</param>
        /// <param name="endRow">Optional end row of the worksheet</param>
        /// <param name="endCol">Optional end column of the worksheet</param>
        /// <returns></returns>
        /// <exception cref="DuplicateNameException">Thrown when the sheet contains a duplicate column</exception>
        public static DataTable ConvertToDataTable(ExcelWorksheet excelWorksheet, int? startRow = null, int? startCol = null, int? endRow = null, int? endCol = null, Dictionary<string, string> columnType = null)
        {
            DataTable table = new DataTable();

            //If any parameters weren't provided, set them accordingly - assign to regular int (not nullable)
            int iStartRow = startRow ?? excelWorksheet.Dimension.Start.Row;
            int iStartCol = startCol ?? excelWorksheet.Dimension.Start.Column;
            int iEndRow = endRow ?? excelWorksheet.Dimension.End.Row;
            int iEndCol = endCol ?? excelWorksheet.Dimension.End.Column;

            List<string> duplicateColumns = new List<string>();
            string errorMessage = "";

            //Iterate the header row, creating a datatable column for each
            for(int colNum = iStartCol; colNum <= iEndCol; colNum++)
            {
                var headerCell = excelWorksheet.Cells[iStartRow, colNum];
                try
                {
                    table.Columns.Add(headerCell.Text.Trim());
                }
                catch (DuplicateNameException)
                {
                    duplicateColumns.Add(headerCell.Text.Trim());
                }
            }
            //If duplicates throw exception
            if(duplicateColumns.Count > 0)
                throw new DuplicateNameException(string.Format("Error processing sheet {0} - duplicate column(s) {1} found", excelWorksheet.Name, string.Join(", ", duplicateColumns)));

            //Iterate all data rows, adding to the datatable where an item # exists
            for (int rowNum = iStartRow + 1; rowNum <= iEndRow; rowNum++)
            {
                //Read this row, and add to a newrow variable. Cleanse empty values to Null
                var row = excelWorksheet.Cells[rowNum, iStartCol, rowNum, iEndCol];
                var newRow = table.NewRow();
                object cellVal;
                bool isRowEmpty = true;
                foreach (var bodyCell in row)
                {
                    cellVal = VDUVerification.nZ(bodyCell.Value, null);

                    if (isRowEmpty && cellVal != null)
                        isRowEmpty = false;

                    //cell type check 
                    if (columnType != null)
                    {
                        string columnName = table.Columns[bodyCell.Start.Column - iStartCol].ToString();
                        string cellType = columnType[columnName];

                        string[] splitstring = null;
                        int? stringLen = null;

                        if (cellType.Contains("-"))
                        {
                            splitstring = cellType.Split('-');
                            cellType = splitstring[0];

                            if (cellType == "string") stringLen = int.Parse(splitstring[1]);
                            else if (cellType == "option")
                            {
                                var list = new List<string>(splitstring);
                                list.RemoveAt(0);
                                splitstring = list.ToArray();
                            }

                        }

                        if (cellType == "bit")
                        {
                            if (cellVal.ToString() != "1" && cellVal.ToString() != "0" && cellVal != null && cellVal.ToString().ToLower() != "null") {
                                errorMessage += string.Format("- Cell {0} in {1} column should have a value of 1, 0 or null.\r\n\r\n", bodyCell, columnName);
                            }
                        } 
                        else if (cellType == "string")
                        {
                            if (cellVal.ToString().Length > stringLen)
                            {
                                errorMessage += string.Format("- Cell {0} in {1} column should be less than {2} characters.\r\n\r\n", bodyCell, columnName, stringLen);
                            }
                        }
                        else if (cellType == "option")
                        {
                            if (!splitstring.Contains(cellVal.ToString()) && (splitstring.Contains("null") && cellVal.ToString().ToLower() != "null"))
                            {
                                errorMessage += string.Format("- Cell {0} in {1} column should be one of the following options: {2}\r\n\r\n", bodyCell, columnName, String.Join(", ", splitstring));
                            }
                        }


                        newRow[bodyCell.Start.Column - iStartCol] = cellVal;

                    } else
                    {
                        newRow[bodyCell.Start.Column - iStartCol] = cellVal;
                    }


                }
                //Only add rows which are not all null values
                //Avoids junk data from an expanded 'usedRange'
                if(!isRowEmpty)
                    table.Rows.Add(newRow);
            }
            if (errorMessage != "")
                throw new DataException(string.Format("Error processing sheet {0} - cell format incorrect for the following elements:\r\n\r\n{1}", excelWorksheet.Name, errorMessage));

            return table;
        }

        /// <summary>
        /// Attempts to convert all possible doubles in a datatable column to a datetime
        /// </summary>
        /// <param name="dataTable">The datatable containing a double column</param>
        /// <param name="columnName">The column name containing the double values (date serials)</param>
        /// <returns></returns>
        public static void DtDoubleToDateTime(DataTable dataTable, string columnName)
        {
            foreach (DataRow dataRow in dataTable.Rows)
            {
                if (double.TryParse(dataRow[columnName].ToString(), out double myDbl) == true)
                {
                    try
                    {
                        DateTime myDate = DateTime.FromOADate(myDbl);
                        dataRow[columnName] = myDate;
                    }
                    catch
                    {

                    }
                }
            }
        }

        /// <summary>
        /// Attempts to convert all possible scientific values to a decimal format
        /// </summary>
        /// <param name="dataTable">The datatable containing a decimal column</param>
        /// <param name="columnName">The column name containing the scientific values</param>
        /// <returns></returns>
        public static void DtScientificToDecimal(DataTable dataTable, string columnName)
        {
            string doubleFixedPoint = "0." + new string('#', 339);
            foreach (DataRow dataRow in dataTable.Rows)
            {
                if (double.TryParse(dataRow[columnName].ToString(), NumberStyles.Number | NumberStyles.AllowExponent | NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out double myDbl) == true)
                {
                    dataRow[columnName] = myDbl.ToString(doubleFixedPoint);
                }
            }
        }

        /// <summary>
        /// Gets the Excel column letter
        /// </summary>
        /// <param name="colNum">Column number (1-based)</param>
        /// <returns>Column letter</returns>
        public static string GetExcelColumnLetter(int colNum)
        {
            string columnName = String.Empty;
            int modulo;

            while (colNum > 0)
            {
                modulo = (colNum - 1) % 26; //26 is 'Z' - 'A' + 1
                columnName = Convert.ToChar('A' + modulo).ToString() + columnName;
                colNum = (int)((colNum - modulo) / 26);
            }

            return columnName;
        }

        /// <summary>
        /// Gets the Excel cell identifier
        /// </summary>
        /// <param name="colNum">Column number (1-based)</param>
        /// <param name="rowNum">Row number</param>
        /// <returns>Cell identifier</returns>
        public static string GetExcelCellId(int colNum, int rowNum)
        {
            return GetExcelColumnLetter(colNum) + rowNum.ToString();
        }
    }
}