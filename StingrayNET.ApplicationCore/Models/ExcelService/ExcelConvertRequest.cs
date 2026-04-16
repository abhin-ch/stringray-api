using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.ExcelService
{
    public class ExcelConvertRequest
    {
        public string FileName { get; private set; }

        public List<ExcelConvertSheet>? Worksheets { get; private set; }

        public ExcelConvertRequest(string fileName, List<ExcelConvertSheet> worksheets)
        {
            FileName = fileName;
            Worksheets = worksheets;
        }

    }
}
