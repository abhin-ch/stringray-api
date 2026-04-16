using System;
using System.Collections.Generic;

#nullable disable

namespace StingrayNET.ApplicationCore.Specifications.Request
{
    public class RequestBody
    {
        public Dictionary<string, object> Data { get; set; }

        public T GetValue<T>(string name)
        {
            try
            {
                if (!Data.ContainsKey(name) && Data[name] == null) return default(T);

                Type type = typeof(T);
                switch (type.Name)
                {
                    case "String":
                        {
                            var value = Data[name].ToString();
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Int32":
                        {
                            var value = Convert.ToInt32(Data[name].ToString());
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Float":
                        {
                            var value = Convert.ToSingle(Data[name]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Double":
                        {
                            var value = Convert.ToDouble(Data[name]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Decimal":
                        {
                            var value = Convert.ToDecimal(Data[name]);
                            return (T)Convert.ChangeType(value, type);
                        }
                    case "Boolean":
                        {
                            if(bool.TrueString.Equals(Data[name].ToString()) || bool.FalseString.Equals(Data[name].ToString())){
                                var boolString = Convert.ToBoolean(Data[name].ToString());
                                return (T)Convert.ChangeType(boolString, type);
                            }

                            var value = Convert.ToInt32(Data[name].ToString());
                            var boolValue = Convert.ToBoolean(value);
                            return (T)Convert.ChangeType(boolValue, type);
                        }
                    case "DateTime":
                        {
                            var value = DateTime.Parse(Data[name].ToString());
                            return (T)Convert.ChangeType(value, type);
                        }
                    default:
                        break;
                }
            }
            catch
            {
            }
            return default(T);
        }
    }
}
#nullable enable