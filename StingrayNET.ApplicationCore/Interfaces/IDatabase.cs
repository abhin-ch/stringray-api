using Microsoft.Data.SqlClient;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Data;
namespace StingrayNET.ApplicationCore.Interfaces;

public interface IDatabase<K> where K : IDepartment
{
    Task<List<object>> ExecuteReaderAsync(string query, List<SqlParameter> parameters = null!, int timeout = 120);
    Task<IReadOnlyDictionary<int, List<object>>> ExecuteReaderSetAsync(string query, List<SqlParameter> parameters = null!, int timeout = 120);
    Task<int> ExecuteNonQueryAsync(string query, List<SqlParameter> parameters = null!, int timeout = 120);
    Task<DataTable> ExecuteReaderDTAsync(string query, List<SqlParameter> parameters = null!, int timeout = 120);
    Task<List<SqlParameter>> ExecuteNonQueryAsyncReturn(string query, List<SqlParameter> parameters, int timeout = 120);
    Task<DataTable> GetReaderSchemaAsync(string query, List<SqlParameter>? parameters = null, int timeout = 120);
    Task BulkInsertAsync(DataTable dataTable, string destinationTable, int batchSize = 10000, int timeout = 120);
}