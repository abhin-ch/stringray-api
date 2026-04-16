using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models.ExcelService;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Interfaces;

public interface IExcelService
{
    public Task<FileStreamResult> Convert(ExcelConvertRequest excelConvertRequest, Dictionary<string, List<object>> datasets);

}
