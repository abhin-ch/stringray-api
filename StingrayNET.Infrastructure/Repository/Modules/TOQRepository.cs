using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.TOQ;
using StingrayNET.ApplicationCore.HelperFunctions;
using System.Linq;
using StingrayNET.ApplicationCore.Models;
using System.Collections.Generic;
using Serilog;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class TOQRepository : BaseRepository<TOQResult>, IRepositoryL<Procedure, TOQResult>
{
    private readonly IEmailService _emailService;
    private readonly ILogger _logger;
    public TOQRepository(IDatabase<DED> ded, IDatabase<SC> sc, IEmailService emailService, Serilog.ILogger logger) : base(ded, sc)
    {
        _emailService = emailService;
        _logger = logger;
    }

    protected override string Query => "stng.SP_TOQ_CRUD";
    protected string QueryAdmin => "stng.SP_TOQ_Permission";
    protected string QueryEmail => "stng.SP_TOQ_Emails";
    public async Task<TOQResult> Op_01(Procedure model = null)
    {
        switch (model.SubOp)
        {
            case 3:
                {
                    //create TOQ
                    model.SubOp = 1;
                    var result = await ExecuteReader<DED>(1, model);

                    //link TOQ to Emergement records
                    model.SubOp = 3;
                    model.Value1 = DataParser.GetValueFromData<string>(result.Data1, "PrimaryKey");
                    return await ExecuteReader<DED>(1, model);


                }
            case 2://TOQ Status update
                {
                    return await ExecuteReader<DED>(1, model);
                }
            default:
                {
                    return await ExecuteReader<DED>(1, model);
                }
        }
    }

    public async Task<TOQResult> Op_02(Procedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<TOQResult> Op_03(Procedure model = null)
    {
        return await ExecuteReaderValidation<DED>(3, model);
    }

    public async Task<TOQResult> Op_04(Procedure model = null)
    {
        var result = await ExecuteReader<DED>(4, model);
        switch (model.SubOp)
        {
            case 1:
                {
                    var typeOptions = result;
                    if (model.Value1 == DEDStatusEnum.APPC.ToString())
                    {
                        result.Data1 = typeOptions.Data1.Cast<dynamic>().Where(o => o.Value1 != "SVN").ToList();
                    }
                    break;
                }
        }
        return result;
    }

    public async Task<TOQResult> Op_05(Procedure model = null)
    {
        return await ExecuteReaderValidation<DED>(5, model);
    }

    public async Task<TOQResult> Op_06(Procedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
        //subop 1 - get
        //subop 2 - vendor correspondence question
        //subop 3 - vendor correspondence answer
        //subop 4 - get oe correspondence
        //subop 5 - oe correspondence question
        //subop 6 - oe correspondence answer
        //subop 7 - vendor correspondence date extension (question)
        //subop 8 - get vendor correspondence answer
        //subop 9 - oe correspondence date extension
    }

    public async Task<TOQResult> Op_07(Procedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<TOQResult> Op_08(Procedure model = null)
    {
        switch (model.SubOp)
        {
            case 1:
                {
                    if (string.IsNullOrEmpty(model.Value2))
                    {
                        throw new ArgumentNullException("ClassV Name is empty");
                    }
                    break;
                }
            case 13:
                {
                    if (string.IsNullOrEmpty(model.Value2))
                    {
                        throw new ArgumentNullException("ClassV Name is empty");
                    }
                    if (string.IsNullOrEmpty(model.Value1))
                    {
                        throw new ArgumentNullException("UniqueID not given");
                    }
                    break;
                }
            default: break;
        }
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<TOQResult> Op_09(Procedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<TOQResult> Op_10(Procedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<TOQResult> Op_11(Procedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<TOQResult> Op_12(Procedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<TOQResult> Op_13(Procedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<TOQResult> Op_14(Procedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<TOQResult> Op_15(Procedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public Task<TOQResult> Op_16(Procedure model = null)
    {
        return ExecuteReaderValidation<DED>(16, model);

    }
    public async Task<TOQResult> Op_17(Procedure model = null)
    {
        // return ExecuteReaderValidation<DED>(17, model);
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<TOQResult> Op_18(Procedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<TOQResult> Op_19(Procedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<TOQResult> Op_20(Procedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<TOQResult> Op_21(Procedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<TOQResult> Op_22(Procedure model = null)
    {
        return await ExecuteReader<DED>(Convert.ToByte(model.SubOp), model, QueryAdmin);
    }

    public async Task<TOQResult> Op_23(Procedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<TOQResult> Op_24(Procedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<TOQResult> Op_25(Procedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<TOQResult> Op_26(Procedure model = null)
    {
        // Used for Emails
        return await ExecuteReader<DED>(1, model, QueryEmail);
    }

    public async Task<TOQResult> Op_27(Procedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<TOQResult> Op_28(Procedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<TOQResult> Op_29(Procedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public async Task<TOQResult> Op_30(Procedure model = null)
    {
        return await ExecuteReader<DED>(30, model);
    }

    public async Task<TOQResult> Op_31(Procedure model = null)
    {
        return await ExecuteReader<DED>(31, model);
    }

    public async Task<TOQResult> Op_32(Procedure model = null)
    {
        return await ExecuteReader<DED>(32, model);
    }

    public async Task<TOQResult> Op_33(Procedure model = null)
    {
        return await ExecuteReader<DED>(33, model);
    }

    public async Task<TOQResult> Op_34(Procedure model = null)
    {
        return await ExecuteReader<DED>(34, model);
    }

    public async Task<TOQResult> Op_35(Procedure model = null)
    {
        return await ExecuteReader<DED>(35, model);
    }

    public Task<TOQResult> Op_36(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_37(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_38(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_39(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_40(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_41(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_42(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_43(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_44(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TOQResult> Op_45(Procedure model = null)
    {
        throw new NotImplementedException();
    }
}
