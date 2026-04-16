using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Reflection;
using System.Linq;
using System.Collections;
using System;
using System.Linq.Expressions;

namespace StingrayNET.ApplicationCore
{
    public static class Extensions
    {
        public static Func<dynamic, bool> Filter(this List<object> data, Dictionary<string, object> predicate)
        {
            var parameter = Expression.Parameter(typeof(object), "row");
            Expression body = Expression.Constant(true);

            foreach (var kvp in predicate)
            {
                string key = kvp.Key;
                object value = kvp.Value;

                Expression keyExpression = Expression.Constant(key);
                Expression valueExpression = Expression.Constant(value);

                Expression containsKey = Expression.Call(parameter, "ContainsKey", null, keyExpression);
                Expression keyValueEqual = Expression.Equal(Expression.Property(parameter, key), valueExpression);

                Expression condition = Expression.AndAlso(containsKey, keyValueEqual);

                body = Expression.AndAlso(body, condition);
            }

            Expression<Func<object, bool>> lambda = Expression.Lambda<Func<object, bool>>(body, parameter);

            return row => lambda.Compile()(row);
        }

        public static List<SqlParameter> AddParameter(this List<SqlParameter> parameters, string parameterName, System.Data.SqlDbType sqlDbType,
            object? value = null, int size = -1, System.Data.ParameterDirection direction = System.Data.ParameterDirection.Input)
        {
            parameters.Add(new SqlParameter
            {
                SqlDbType = sqlDbType,
                ParameterName = parameterName,
                Value = value,
                Size = size,
                Direction = direction
            });
            return parameters;
        }

        public static DataTable ToDataTable(this IList items)
        {
            //Return null if the IEnum is null or empty
            if (items == null)
            {
                return null;
            }

            if (items.Count == 0)
            {
                return null;
            }

            //Instantiate DT and add columns
            DataTable dt = new DataTable();
            var firstItem = items[0];

            foreach (PropertyInfo prop in firstItem.GetType().GetProperties())
            {
                dt.Columns.Add(new DataColumn(prop.Name, prop.PropertyType));
            }

            //Add rows
            foreach (var item in items)
            {
                dt.Rows.Add();

                foreach (PropertyInfo prop in item.GetType().GetProperties())
                {
                    dt.Rows[dt.Rows.Count - 1][prop.Name] = prop.GetValue(item, null);
                }

            }

            return dt;

        }
    }
}
