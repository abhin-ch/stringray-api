using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.IQT;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class IQTRepository : BaseRepository<IQTResult>, IRepositoryM<IQTProcedure, IQTResult>
{
    protected override string Query => "stng.SP_IQT_CRUD";


    public IQTRepository(IDatabase<DED> mssql) : base(mssql)
    {
    }
    public async Task<IQTResult> Op_01(IQTProcedure model = null)
    {

        //Get all 1-10 number strings delimited by non-numbers
        string pattern = @"(?<=^|[^0-9])[0-9]{1,10}(?=$|[^0-9])";

        MatchCollection distinctItems = Regex.Matches(model.ITEMNUM, pattern);

        //Instantiate runningItemList
        DataTable runningItemList = new DataTable();
        runningItemList.Columns.Add(new DataColumn("ITEMNUM", typeof(string)));

        //Loop through distinctItems, pad with zeroes, and add to runningItemList
        foreach (Match distinctItem in distinctItems)
        {
            runningItemList.Rows.Add();

            //TWC.RadMessageBox.Show(runningItemList.Rows.Count.ToString());
            if (distinctItem.Value.Length <= 10)
            {
                runningItemList.Rows[runningItemList.Rows.Count - 1][0] = new string('0', 10 - distinctItem.Value.Length) + distinctItem.Value;
            }
            else
            {
                runningItemList.Rows[runningItemList.Rows.Count - 1][0] = distinctItem.Value;
            }
        }

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 1);
        parameters.AddParameter("@ItemList", SqlDbType.Structured, runningItemList);

        var result = new IQTResult();
        result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
        return result;
    }

    public async Task<IQTResult> Op_02(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<IQTResult> Op_03(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<IQTResult> Op_04(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<IQTResult> Op_05(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<IQTResult> Op_06(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<IQTResult> Op_07(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<IQTResult> Op_08(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<IQTResult> Op_09(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<IQTResult> Op_10(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<IQTResult> Op_11(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<IQTResult> Op_12(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<IQTResult> Op_13(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<IQTResult> Op_14(IQTProcedure model = null)
    {

        //Get all distinct words delimited by spaces
        string pattern = @"(?<=^|\s)[^\s]+(?=$|\s)";
        MatchCollection distinctWords = Regex.Matches(model.ItemList, pattern);

        //Instantiate runningItemList
        DataTable runningItemList = new DataTable();
        runningItemList.Columns.Add(new DataColumn("ITEMNUM", typeof(string)));

        await Task.Run(async () =>
        {

            foreach (Match distinctWord in distinctWords)
            {
                //Instantiate tempParameters
                List<SqlParameter> tempParameters = new List<SqlParameter>();
                tempParameters.AddParameter("@Operation", SqlDbType.TinyInt, 14);
                tempParameters.AddParameter("@GetDistinctItems", SqlDbType.Bit, true);
                tempParameters.AddParameter("@ItemList", SqlDbType.Structured, runningItemList);
                tempParameters.AddParameter("@ITEMDESC", SqlDbType.VarChar, distinctWord.Value.ToString());

                //Get itemList
                DataTable itemList = await _ded.ExecuteReaderDTAsync(Query, tempParameters);

                //Set runningItemList
                runningItemList = itemList;
            }

        });

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 14);
        parameters.AddParameter("@ItemList", SqlDbType.Structured, runningItemList);

        var result = new IQTResult();

        result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
        return result;
    }

    public async Task<IQTResult> Op_15(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<IQTResult> Op_16(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<IQTResult> Op_17(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<IQTResult> Op_18(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<IQTResult> Op_19(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<IQTResult> Op_20(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<IQTResult> Op_21(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<IQTResult> Op_22(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<IQTResult> Op_23(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<IQTResult> Op_24(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<IQTResult> Op_25(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<IQTResult> Op_26(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<IQTResult> Op_27(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<IQTResult> Op_28(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<IQTResult> Op_29(IQTProcedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public Task<IQTResult> Op_30(IQTProcedure model = null)
    {
        throw new NotImplementedException();
    }
}