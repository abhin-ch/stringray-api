using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore.Specifications;
using System.Collections;
using StingrayNET.ApplicationCore.HelperFunctions;

namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseProcedure
{
    const int MAX_STRING_SIZE = 4000;
    public byte? SubOp { get; set; } = null;
    public string? EmployeeID { get; set; } = null;
    public string? Value1 { get; set; } = null;
    public string? Value2 { get; set; } = null;
    public string? Value3 { get; set; } = null;
    public string? Value4 { get; set; } = null;
    public string? Value5 { get; set; } = null;
    public string? Value6 { get; set; } = null;
    public string? Value7 { get; set; } = null;
    public string? Value8 { get; set; } = null;
    public string? Value9 { get; set; } = null;
    public string? Value10 { get; set; } = null;
    public string? Value11 { get; set; } = null;
    public string? Value12 { get; set; } = null;
    public string? Value13 { get; set; } = null;
    public int? Num1 { get; set; } = null;
    public int? Num2 { get; set; } = null;
    public int? Num3 { get; set; } = null;
    public decimal? Decimal1 { get; set; } = null;
    public decimal? Decimal2 { get; set; } = null;
    public decimal? Decimal3 { get; set; } = null;
    public DateTime? Date1 { get; set; } = null;
    public DateTime? Date2 { get; set; } = null;
    public DateTime? Date3 { get; set; } = null;
    public DateTime? Date4 { get; set; } = null;
    public DateTime? Date5 { get; set; } = null;
    public bool? IsTrue1 { get; set; } = null;
    public bool? IsTrue2 { get; set; } = null;
    public bool? IsTrue3 { get; set; } = null;
    public bool? IsTrue4 { get; set; } = null;
    public bool? IsTrue5 { get; set; } = null;

    public static List<SqlParameter> SetOperation(int operation)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, operation);
        return parameters;
    }
    public virtual List<SqlParameter> GetParameters(int operation)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        Type type = GetType();
        foreach (var property in type.GetProperties())
        {
            // Don't include property if not assigned or if decorated with StoredProcIgnore attribute
            if (property.GetValue(this) == null || Attribute.IsDefined(property, typeof(StoredProcIgnore)))
            {
                continue;
            }

            //Get underlying type
            Type? underlyingType = Nullable.GetUnderlyingType(property.PropertyType) == null ? property.PropertyType : Nullable.GetUnderlyingType(property.PropertyType);

            //Test if List generic
            //TODO - Decide conventionally which property types are converted to Structured SQLDbTypes
            if (underlyingType!.IsGenericType)
            {
                var typeDef = underlyingType.GetGenericTypeDefinition();
                switch (typeDef)
                {
                    case Type listType when listType.IsAssignableFrom(typeof(List<>)):
                        {
                            //First, cast to IList
                            IList? castList = property.GetValue(this) as IList;

                            //Next, get internal type of casted IList
                            Type internalType = castList!.GetType().GetGenericArguments()[0];

                            //Next, check if internalType is a class and in the StingrayNET.ApplicationCore namespace
                            if (internalType.IsClass && internalType.FullName!.StartsWith(@"StingrayNET.ApplicationCore"))
                            {
                                //Convert to datatable
                                DataTable dt = castList.ToDataTable();

                                //Add parameter
                                parameters.AddParameter($"@{property.Name}", SqlDbType.Structured, dt);
                            }
                            break;
                        }
                    case Type listType when listType.IsAssignableFrom(typeof(TableType<>)):
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.Structured, property.GetValue(this));
                            break;
                        }
                }
            }

            else
            {
                switch (Type.GetTypeCode(underlyingType))
                {
                    case TypeCode.Char:
                    case TypeCode.String:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.VarChar, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Boolean:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.Bit, property.GetValue(this));
                            break;
                        }
                    case TypeCode.DateTime:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.DateTime, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Decimal:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.Decimal, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Int16:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.SmallInt, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Int32:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.Int, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Int64:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.BigInt, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Byte:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.TinyInt, property.GetValue(this));
                            break;
                        }
                    case TypeCode.Single:
                    case TypeCode.Double:
                        {
                            parameters.AddParameter($"@{property.Name}", SqlDbType.Float, property.GetValue(this));
                            break;
                        }
                    default:
                        break;
                        //throw new NotSupportedException($"TypeCode of ({Type.GetTypeCode(underlyingType)}) not supported. Please contact your System Admin");
                }
            }

        }
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, operation);
        return parameters;
    }
}
