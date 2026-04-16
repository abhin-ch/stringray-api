using OfficeOpenXml.Style;
using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.ExcelService
{
    public class ExcelConvertSheet
    {
        public string SheetName { get; private set; }
        public ExcelCellFormat? HeaderCellFormat { get; private set; }
        public ExcelCellFormat? BodyCellFormat { get; private set; }

        public ExcelConvertSheet(string sheetName, ExcelCellFormat? headerCellFormat = null, ExcelCellFormat? bodyCellFormat = null)
        {
            SheetName = sheetName;

            //If no headerCellFormat provided, provide a default one (DFDFDF grey BG, bold font)
            if (headerCellFormat == null)
            {
                HeaderCellFormat = new ExcelCellFormat(bold: true, bgcolour: @"#DFDFDF");
            }

            else
            {
                HeaderCellFormat = headerCellFormat;
            }

            //If no bodyCellFormat provided, just use the Excel defaults
            BodyCellFormat = bodyCellFormat;

        }

    }
}
