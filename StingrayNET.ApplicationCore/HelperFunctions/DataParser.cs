using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;

namespace StingrayNET.ApplicationCore.HelperFunctions;

public class DataParser
{
#nullable enable

    public static T? GetValueFromData<T>(List<object> data, string columnName)
    {
        if (data == null || data.Count == 0)
        {
            return default(T);
        }
        try
        {
            var temp = (Dictionary<string, object>)data[0];
            // Check if the specified column exists        
            if (!temp.ContainsKey(columnName))
            {
                return default(T);
            }
            object value = temp[columnName];
            // Handle nullable types separately        
            Type targetType = Nullable.GetUnderlyingType(typeof(T)) ?? typeof(T);
            if (value == null || value is DBNull)
            {
                return default(T);
            }
            // Convert to target type     
            return (T)Convert.ChangeType(value, targetType);
        }
        catch (Exception)
        {
            return default(T);
        }
    }

    public static T? GetValueFromData<T>(object data, string columnName)
    {
        if (data == null)
        {
            return default(T);
        }

        if (data?.GetType().IsGenericType == true && data.GetType().GetGenericTypeDefinition() == typeof(List<>))
        {
            // data is a List
            return default(T);
        }
        try
        {
            var temp = (Dictionary<string, object>)data;
            // Check if the specified column exists        
            if (!temp.ContainsKey(columnName))
            {
                return default(T);
            }
            object value = temp[columnName];
            // Handle nullable types separately        
            Type targetType = Nullable.GetUnderlyingType(typeof(T)) ?? typeof(T);
            if (value == null || value is DBNull)
            {
                return default(T);
            }
            // Convert to target type     
            return (T)Convert.ChangeType(value, targetType);
        }
        catch (Exception)
        {
            return default(T);
        }
    }

    public static List<string> GetListFromData(List<object> data, string columnName)
    {
        try
        {
            var temp = (Dictionary<string, object>)data[0];
            return data.Select(to =>
            {
                var toDict = (Dictionary<string, object>)to;
                return (string)toDict[columnName];
            }).ToList();
        }
        catch (Exception)
        {
            return new List<string>();
        }

    }

    public static List<T> GetListFromData<T>(List<object> data, string columnName)
    {
        var result = new List<T>();

        if (data == null || data.Count == 0)
            return result;

        try
        {
            foreach (var item in data)
            {
                if (item is Dictionary<string, object> dict &&
                    dict.TryGetValue(columnName, out var value) &&
                    value != null)
                {
                    result.Add((T)Convert.ChangeType(value, typeof(T)));
                }
            }
        }
        catch
        {
            return new List<T>();
        }

        return result;
    }

    public static T? GetModelFromObject<T>(object value) where T : new()
    {
        try
        {
            if (value == null || (value is string strValue && string.IsNullOrEmpty(strValue)))
            {
                return default(T);
            }

            var jsonString = JsonSerializer.Serialize(value);
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };

            // Convert empty strings to null before deserializing
            jsonString = jsonString.Replace("\"\"", "null");

            var model = JsonSerializer.Deserialize<T>(jsonString, options);
            return model;
        }
        catch (Exception)
        {
            return default(T);
        }
    }
}
#nullable disable