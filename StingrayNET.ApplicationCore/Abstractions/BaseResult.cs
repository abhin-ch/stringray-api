using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Specifications;
using System;
using StingrayNET.ApplicationCore.Models;
using OfficeOpenXml.FormulaParsing.Excel.Functions.Text;

namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseResult : JsonResult
{
    public BaseResult() : base(null)
    {
        throw new NotImplementedException();
    }
    public BaseResult(object value) : base(value)
    {
    }

    public static BaseResult JsonResult<T>(object result) where T : BaseResult
    {
        switch (typeof(T).Name)
        {
            case nameof(HttpSuccess):
                return new HttpSuccess(result);
            case nameof(HttpError):
                return new HttpError(new Exception(Convert.ToString(result)));
        }
        return new HttpError(new Exception($"{typeof(T).Name} not found"));
    }

    public static BaseResult JsonResult<T>() where T : BaseResult
    {
        return JsonResult<T>("");
    }

    public static BaseResult JsonResult<T>(T result) where T : BaseOperation
    {
        return JsonResult<HttpSuccess>(result);
    }
}

public class Return<T> : BaseResult where T : class
{
    public ErrorResponse error { get; set; } = null!;
    public T body { get; set; } = null!;
}