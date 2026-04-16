using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;

namespace StingrayNET.Infrastructure.Services
{
    /// <summary>
    /// A generic, reusable data access class for executing stored procedures against SQL Server.
    /// Uses connection pooling efficiently by creating short-lived connections for each operation.
    /// </summary>
    public class MSSQL<T> : IDatabase<T> where T : IDepartment
    {
        private readonly string _connectionString;

        /// <summary>
        /// The connection string is injected by the DI container.
        /// This enables efficient connection pooling by creating connections only when needed.
        /// </summary>
        public MSSQL(string connectionString)
        {
            _connectionString = connectionString ?? throw new ArgumentNullException(nameof(connectionString));
        }

        /// <summary>
        /// Executes a query that doesn't return any data (e.g., INSERT, UPDATE, DELETE).
        /// </summary>
        public async Task<int> ExecuteNonQueryAsync(string query, List<SqlParameter> parameters = null, int timeout = 120)
        {
            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            await using var command = new SqlCommand(query, connection)
            {
                CommandTimeout = timeout,
                CommandType = CommandType.StoredProcedure
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            return await command.ExecuteNonQueryAsync();
        }

        /// <summary>
        /// Executes a query and returns any output parameters from the stored procedure.
        /// </summary>
        public async Task<List<SqlParameter>> ExecuteNonQueryAsyncReturn(string query, List<SqlParameter> parameters, int timeout = 120)
        {
            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            await using var command = new SqlCommand(query, connection)
            {
                CommandTimeout = timeout,
                CommandType = CommandType.StoredProcedure
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            await command.ExecuteNonQueryAsync();

            // Return any parameters that were marked as Output or InputOutput.
            return command.Parameters.Cast<SqlParameter>()
                .Where(p => p.Direction == ParameterDirection.Output || p.Direction == ParameterDirection.InputOutput)
                .ToList();
        }

        /// <summary>
        /// Returns the schema of a query result as a DataTable.
        /// </summary>
        /// <param name="query"></param>
        /// <param name="parameters"></param>
        /// <param name="timeout"></param>
        /// <returns>DataTable</returns>
        public async Task<DataTable> GetReaderSchemaAsync(string query, List<SqlParameter> parameters = null, int timeout = 120)
        {
            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            await using var command = new SqlCommand(query, connection)
            {
                CommandTimeout = timeout,
                CommandType = CommandType.StoredProcedure
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            // CommandBehavior.KeyInfo is required to get detailed schema information.
            await using var reader = await command.ExecuteReaderAsync(CommandBehavior.KeyInfo);
            return await reader.GetSchemaTableAsync();
        }

        /// <summary>
        /// Executes a query and returns a single result set as a list of objects.
        /// </summary>
        /// <param name="query"></param>
        /// <param name="parameters"></param>
        /// <param name="timeout"></param>
        /// <returns>List<object></returns>
        public async Task<List<object>> ExecuteReaderAsync(string query, List<SqlParameter> parameters = null, int timeout = 120)
        {
            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            await using var command = new SqlCommand(query, connection)
            {
                CommandTimeout = timeout,
                CommandType = CommandType.StoredProcedure
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            var rows = new List<object>();
            await using var reader = await command.ExecuteReaderAsync();

            var fieldCount = reader.FieldCount;
            var columnNames = new string[fieldCount];

            // Cache column names once before reading rows
            for (var i = 0; i < fieldCount; i++)
                columnNames[i] = reader.GetName(i);

            while (await reader.ReadAsync())
            {
                // Pre-size dictionary for efficiency
                var row = new Dictionary<string, object>(fieldCount, StringComparer.OrdinalIgnoreCase);
                for (var i = 0; i < fieldCount; i++)
                {
                    var value = reader.IsDBNull(i) ? "" : reader.GetValue(i);
                    row[columnNames[i]] = value;
                }
                rows.Add(row);
            }

            return rows;
        }

        /// <summary>
        /// Executes a query and returns the result as a DataTable.
        /// </summary>
        public async Task<DataTable> ExecuteReaderDTAsync(string query, List<SqlParameter> parameters = null, int timeout = 120)
        {
            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            await using var command = new SqlCommand(query, connection)
            {
                CommandTimeout = timeout,
                CommandType = CommandType.StoredProcedure
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            var dataTable = new DataTable();
            await using var reader = await command.ExecuteReaderAsync();

            // The .Load() method is a fully async and efficient way to build a DataTable from a reader.
            dataTable.Load(reader);

            return dataTable;
        }

        /// <summary>
        /// Executes a query that returns multiple result sets (e.g., a stored procedure with multiple SELECT statements).
        /// </summary>
        public async Task<IReadOnlyDictionary<int, List<object>>> ExecuteReaderSetAsync(string query, List<SqlParameter> parameters = null, int timeout = 300)
        {
            var resultSet = new Dictionary<int, List<object>>();

            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            await using var command = new SqlCommand(query, connection)
            {
                CommandTimeout = timeout,
                CommandType = CommandType.StoredProcedure
            };

            if (parameters != null)
            {
                command.Parameters.AddRange(parameters.ToArray());
            }

            await using var reader = await command.ExecuteReaderAsync();

            var setIndex = 0;
            do
            {
                var rows = new List<object>();
                var fieldCount = reader.FieldCount;
                var columnNames = new string[fieldCount];

                // Cache column names once per result set
                for (var i = 0; i < fieldCount; i++)
                    columnNames[i] = reader.GetName(i);

                while (await reader.ReadAsync())
                {
                    // Pre-size dictionary for efficiency
                    var row = new Dictionary<string, object>(fieldCount, StringComparer.OrdinalIgnoreCase);
                    for (var i = 0; i < fieldCount; i++)
                    {
                        var value = reader.IsDBNull(i) ? "" : reader.GetValue(i);
                        row[columnNames[i]] = value;
                    }
                    rows.Add(row);
                }

                resultSet.Add(setIndex, rows);
                setIndex++;
            } while (await reader.NextResultAsync()); // Move to the next result set.

            return resultSet;
        }
        /// <summary>
        /// Performs a bulk insert of data into a target table. Note that SELECT + INSERT permissions are required on the target table
        /// </summary>
        public async Task BulkInsertAsync(DataTable dataTable, string destinationTable, int batchSize = 10000, int timeout = 120)
        {
            if (dataTable == null) throw new ArgumentNullException(nameof(dataTable));
            if (string.IsNullOrWhiteSpace(destinationTable)) throw new ArgumentNullException(nameof(destinationTable));

            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using var bulkCopy = new SqlBulkCopy(connection)
            {
                DestinationTableName = destinationTable,
                BatchSize = batchSize,
                BulkCopyTimeout = timeout
            };

            // Map columns automatically by name
            foreach (DataColumn column in dataTable.Columns)
            {
                bulkCopy.ColumnMappings.Add(column.ColumnName, column.ColumnName);
            }

            await bulkCopy.WriteToServerAsync(dataTable);
        }

    }
}