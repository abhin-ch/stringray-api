using System;
using Microsoft.Data.SqlClient;

namespace StingrayNET.ApplicationCore
{
    public static class ModelExtensions
    {
        public static T? GetProperty<T>(this SqlDataReader reader, string columnName) where T : IEquatable<T>
        {
            try
            {
                Type type = typeof(T);

                if (reader[columnName] == DBNull.Value) return default(T);

                switch (type.Name)
                {
                    case "String":
                        {
                            var value = reader[columnName].ToString();
                            return (T)Convert.ChangeType(value ?? "", type);
                        }
                    case "Int32":
                        {
                            var value = Convert.ToInt32(reader[columnName]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Float":
                        {
                            var value = Convert.ToSingle(reader[columnName]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Double":
                        {
                            var value = Convert.ToDouble(reader[columnName]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Decimal":
                        {
                            var value = Convert.ToDecimal(reader[columnName]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Boolean":
                        {
                            var value = Convert.ToInt32(reader[columnName]);
                            var boolValue = Convert.ToBoolean(value);
                            return (T)Convert.ChangeType(boolValue, type);
                        }
                    case "DateTime":
                        {
                            var value = DateTime.Parse(reader[columnName].ToString() ?? "");
                            return (T)Convert.ChangeType(value, type);
                        }
                    default:
                        break;
                }
            }
            catch(Exception)
            {
            }
            return default(T);
        }
    }
}
