using Microsoft.Data.SqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Data;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Infrastructure.Repository;

//REDO with IDatabase<T> injection
public class ExpressionRepository : IExpressionRepository
{
    private readonly IExpressionSerializer _expressionSerializer;
    private readonly IDatabase<SC> _dbMain;
    private readonly IDatabase<DED> _dbDED;

    public ExpressionRepository(IExpressionSerializer expressionSerializer, IDatabase<SC> main, IDatabase<DED> ded)
    {
        _expressionSerializer = expressionSerializer;
        _dbMain = main;
        _dbDED = ded;
    }

    public async Task<bool> EvaluateExpression(string expressionName, Dictionary<string, Dictionary<string, object>>? datasetParams = null, List<string>? possibleUsers = null)
    {
        //Expression SP Name
        string sp = @"stng.SP_Expression_CRUD";

        //Obtain metadata
        var expReturn = (await _dbMain.ExecuteReaderAsync(sp, new List<SqlParameter>()
            {
                new SqlParameter()
                {
                    ParameterName = @"@Operation",
                    SqlDbType = SqlDbType.Int,
                    Value = 5
                },
                new SqlParameter()
                {
                    ParameterName = @"@ExpressionName",
                    SqlDbType = SqlDbType.VarChar,
                    Value = expressionName
                }
            })).Select(x => (Dictionary<string, object>)x).ToList();

        if (expReturn.Count == 0)
        {
            throw new ArgumentException($"{expressionName} metadata does not exist. Ensure the expression is first added to the database");
        }

        else if (expReturn.Where(x => !string.IsNullOrEmpty(x[@"ParameterName"].ToString())).Count() > 0 && datasetParams == null)
        {
            throw new ArgumentNullException(@"datasetParams", @"Cannot be null as Expression is related to Dataset(s) with Parameters");
        }

        //Obtain datasets and datasetTypes
        List<string> datasetNames = expReturn.Where(x => !string.IsNullOrEmpty(x[@"ExpressionDatasetName"].ToString())).Select(x => x[@"ExpressionDatasetName"].ToString()).Distinct().ToList();

        Dictionary<string, List<Dictionary<string, object>>> datasets = new Dictionary<string, List<Dictionary<string, object>>>();
        Dictionary<string, Dictionary<string, Type>> datasetTypes = new Dictionary<string, Dictionary<string, Type>>();
        foreach (string datasetName in datasetNames)
        {
            sp = expReturn.Where(x => x[@"ExpressionDatasetName"].ToString() == datasetName).FirstOrDefault()[@"SPName"].ToString();

            var currentDatasetReturn = expReturn.Where(x => x[@"ExpressionDatasetName"].ToString() == datasetName);

            //Declare params and get Operation
            List<SqlParameter> sqlParams = new List<SqlParameter>()
                    {
                        new SqlParameter()
                        {
                            ParameterName = @"@Operation",
                            SqlDbType = SqlDbType.Int,
                            Value = currentDatasetReturn.Select(x => Convert.ToInt32(x[@"Operation"])).FirstOrDefault()
                        }
                    };

            var expParams = currentDatasetReturn.Where(x => !string.IsNullOrEmpty(x[@"ParameterName"].ToString()));

            if (expParams.Count() > 0)
            {
                if (!datasetParams.ContainsKey(datasetName))
                {
                    throw new ArgumentException($"Provided datasetParams argument does not contain Dataset {datasetName}");
                }

                Dictionary<string, object> currentDatasetParams = datasetParams[datasetName];

                //Check if provided datasetParams provides a value for each Parameter in exp metadata 
                foreach (var expParam in expParams)
                {
                    if (!currentDatasetParams.ContainsKey(expParam[@"ParameterName"].ToString()))
                    {
                        throw new ArgumentException($"Provided datasetParams argument does not contain a value definition for Parameter {expParam[@"ParameterName"].ToString()} in Dataset {datasetName}");
                    }

                    SqlDbType sqlType = SqlDbType.VarChar;
                    if (!Enum.TryParse<SqlDbType>(expParam[@"ParameterType"].ToString(), true, out sqlType))
                    {
                        throw new Exception($"Cannot convert {expParam[@"ParameterName"].ToString()} to a .NET SQL Type");
                    }

                    sqlParams.Add(new SqlParameter()
                    {
                        ParameterName = $"@{expParam[@"ParameterName"].ToString()}",
                        SqlDbType = sqlType,
                        Value = currentDatasetParams[expParam[@"ParameterName"].ToString()]
                    });

                }

            }

            //Retrieve Dataset and add to datasets
            List<Dictionary<string, object>> datasetReturn = null;
            DataTable schema = null;
            string databaseName = currentDatasetReturn.Select(x => x[@"DatabaseName"].ToString()).FirstOrDefault();
            if (databaseName == @"Engineering")
            {
                datasetReturn = (await _dbDED.ExecuteReaderAsync(sp, sqlParams)).Select(x => (Dictionary<string, object>)x).ToList();
                schema = await _dbDED.GetReaderSchemaAsync(sp, sqlParams);
            }

            else if (databaseName == @"Supply Chain/Main")
            {
                datasetReturn = (await _dbMain.ExecuteReaderAsync(sp, sqlParams)).Select(x => (Dictionary<string, object>)x).ToList();
                schema = await _dbMain.GetReaderSchemaAsync(sp, sqlParams);
            }

            else
            {
                throw new Exception($"Database {databaseName} is not handled. Cannot retrieve Dataset");
            }

            datasets[datasetName] = datasetReturn;

            //Add to datasetTypes
            Dictionary<string, Type> workingDatasetTypes = new Dictionary<string, Type>();
            for (int i = 0; i < schema.Rows.Count; i++)
            {
                workingDatasetTypes[schema.Rows[i][@"ColumnName"].ToString()] = (Type)schema.Rows[i][@"DataType"];
            }

            datasetTypes[datasetName] = workingDatasetTypes;

        }

        //Obtain expression
        string exp = expReturn.Select(x => x[@"Expression"].ToString()).FirstOrDefault();

        //Pass to ExpressionSerializer
        return _expressionSerializer.EvaluateExpression(exp, datasets, datasetTypes, possibleUsers);

    }

}