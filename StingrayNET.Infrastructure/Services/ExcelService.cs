using Microsoft.AspNetCore.Mvc;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.ExcelService;
using System.Threading.Tasks;
using System.Collections.Generic;
using System;
using System.Linq;
using System.IO;
using StingrayNET.ApplicationCore.CustomExceptions;

namespace StingrayNET.Infrastructure.Services;

public class ExcelService : IExcelService
{
    public ExcelService()
    {

    }

    public async Task<FileStreamResult> Convert(ExcelConvertRequest excelConvertRequest, Dictionary<string, List<object>> datasets)
    {
        using (ExcelPackage package = new ExcelPackage())
        {
            foreach (string datasetName in datasets.Keys)
            {
                //Attempt to get excelConvertSheet based on datasetName
                if (!excelConvertRequest.Worksheets.Any(ws => ws.SheetName == datasetName))
                {
                    throw new BadRequestException(string.Format(@"Unable to find ExcelConvertSheet object for dataset named {0}. Ensure the SheetName property is properly specified to align with datasets object", datasetName));

                }

                ExcelConvertSheet shtArgs = excelConvertRequest.Worksheets.Where(ws => ws.SheetName == datasetName).ToList()[0];

                //Instantiate new worksheet
                ExcelWorksheet sht = package.Workbook.Worksheets.Add(datasetName);

                //Add headers
                List<object> dataset = datasets[datasetName];
                Dictionary<string, object> row = (Dictionary<string, object>)(dataset[0]);

                int headerCounter = 0;
                foreach (string col in row.Keys)
                {
                    sht.Cells[1, headerCounter + 1].Value = col;
                    headerCounter++;
                }

                //Apply header formats
                if (shtArgs.HeaderCellFormat != null)
                {
                    sht.Cells[1, 1, 1, headerCounter].Style.Font.Bold = (bool)shtArgs.HeaderCellFormat.Bold;
                    sht.Cells[1, 1, 1, headerCounter].Style.Font.Italic = (bool)shtArgs.HeaderCellFormat.Italic;
                    sht.Cells[1, 1, 1, headerCounter].Style.Font.UnderLine = (bool)shtArgs.HeaderCellFormat.Underlined;

                    sht.Cells[1, 1, 1, headerCounter].Style.Font.Color.SetColor(shtArgs.HeaderCellFormat.FGColourDotnet);

                    sht.Cells[1, 1, 1, headerCounter].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    sht.Cells[1, 1, 1, headerCounter].Style.Fill.BackgroundColor.SetColor(shtArgs.HeaderCellFormat.BGColourDotnet);

                    sht.Cells[1, 1, 1, headerCounter].Style.Border.Left.Style = (ExcelBorderStyle)shtArgs.HeaderCellFormat.LeftBorder;
                    sht.Cells[1, 1, 1, headerCounter].Style.Border.Right.Style = (ExcelBorderStyle)shtArgs.HeaderCellFormat.RightBorder;
                    sht.Cells[1, 1, 1, headerCounter].Style.Border.Top.Style = (ExcelBorderStyle)shtArgs.HeaderCellFormat.TopBorder;
                    sht.Cells[1, 1, 1, headerCounter].Style.Border.Bottom.Style = (ExcelBorderStyle)shtArgs.HeaderCellFormat.BottomBorder;

                }

                //Write body
                int rowCounter = 2;
                foreach (var obj in dataset)
                {
                    //Cast
                    Dictionary<string, object> objRow = (Dictionary<string, object>)(obj);

                    //Loop and write
                    headerCounter = 1;
                    foreach (string col in objRow.Keys)
                    {
                        sht.Cells[rowCounter, headerCounter].Value = objRow[col];

                        //Format based on .NET type
                        switch (Type.GetTypeCode(objRow[col].GetType()))
                        {
                            case TypeCode.DateTime:
                                {
                                    sht.Cells[rowCounter, headerCounter].Style.Numberformat.Format = @"ddMMMyyyy";
                                    break;
                                }
                        }

                        headerCounter++;
                    }

                    rowCounter++;
                }

                //Apply Body formats
                if (shtArgs.BodyCellFormat != null)
                {
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Font.Bold = (bool)shtArgs.BodyCellFormat.Bold;
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Font.Italic = (bool)shtArgs.BodyCellFormat.Italic;
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Font.UnderLine = (bool)shtArgs.BodyCellFormat.Underlined;

                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Font.Color.SetColor(shtArgs.BodyCellFormat.FGColourDotnet);

                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Fill.PatternType = ExcelFillStyle.Solid;
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Fill.BackgroundColor.SetColor(shtArgs.BodyCellFormat.BGColourDotnet);

                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Border.Left.Style = (ExcelBorderStyle)shtArgs.BodyCellFormat.LeftBorder;
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Border.Right.Style = (ExcelBorderStyle)shtArgs.BodyCellFormat.RightBorder;
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Border.Top.Style = (ExcelBorderStyle)shtArgs.BodyCellFormat.TopBorder;
                    sht.Cells[2, 1, rowCounter, headerCounter].Style.Border.Bottom.Style = (ExcelBorderStyle)shtArgs.BodyCellFormat.BottomBorder;
                }

            }

            //Return stream
            byte[] excelBytes = package.GetAsByteArray();
            return new FileStreamResult(new MemoryStream(excelBytes, 0, excelBytes.Length), @"application/octet-stream")
            {
                FileDownloadName = string.Format(@"{0}.xlsx", excelConvertRequest.FileName)
            };
        }
    }

}

