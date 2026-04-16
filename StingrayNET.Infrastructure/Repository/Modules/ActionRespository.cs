using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Actions;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.HelperFunctions;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules
{
    public class ActionRepository : BaseRepository<ActionsResult>, IRepositoryS<ActionsProcedure, ActionsResult>
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IEmailService _emailService;

        public ActionRepository(IDatabase<DED> mssql, IIdentityService identityService, IHttpContextAccessor httpContextAccessor, IEmailService emailService) : base(mssql)
        {
            _httpContextAccessor = httpContextAccessor;
            _emailService = emailService;
        }

        protected override string Query => "stng.SP_MCRE_Actions_CRUD";

        public async Task<ActionsResult> Op_01(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(1, model);
        }

        public async Task<ActionsResult> Op_02(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(2);
        }

        public async Task<ActionsResult> Op_03(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(3);
        }

        public async Task<ActionsResult> Op_04(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(4);
        }

        public async Task<ActionsResult> Op_05(ActionsProcedure model = null)
        {
            model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            var origResult = await ExecuteReader<DED>(5, model);

            var newReuslt = origResult;

            List<string> emailTo = new List<string>();
            string listToItem = DataParser.GetValueFromData<string>(newReuslt.Data1, @"OwnerEmail");
            emailTo.Add(listToItem);

            List<string> emailCC = new List<string>();
            string[] listCCItem = DataParser.GetValueFromData<string>(newReuslt.Data1, @"CreatedByEmail").Split(';');
            foreach (var item in listCCItem)
            {
                emailCC.Add(item);
            }

            string emailBody = DataParser.GetValueFromData<string>(newReuslt.Data2, @"Body");
            string emailSubject = DataParser.GetValueFromData<string>(newReuslt.Data2, @"Subject");

            if (newReuslt.Data1.Count > 0)
            {
                string emailBodyTable1 = await _emailService.ToHTMLTable(newReuslt.Data3);
                string emailBody2 = await _emailService.Inject(emailBody, new Dictionary<string, string>() { { @"ActionItemTable", emailBodyTable1 } });

                EmailTemplate template = new EmailTemplate(toList: emailTo, subject: emailSubject, emailBody: emailBody2, CCList: emailCC);
                await _emailService.Send(template);
            }

            return origResult;
        }

        public async Task<ActionsResult> Op_06(ActionsProcedure model = null)
        {
            model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
            return await ExecuteReader<DED>(6, model);
        }

        public async Task<ActionsResult> Op_07(ActionsProcedure model = null)
        {
            model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
            return await ExecuteReader<DED>(7, model);
        }

        public async Task<ActionsResult> Op_08(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(8, model);
        }

        public async Task<ActionsResult> Op_09(ActionsProcedure model = null)
        {
            model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
            return await ExecuteReader<DED>(9, model);
        }

        public async Task<ActionsResult> Op_10(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(10, model);
        }

        public async Task<ActionsResult> Op_11(ActionsProcedure model = null)
        {
            return await ExecuteReader<DED>(11);
        }

        public Task<ActionsResult> Op_12(ActionsProcedure model = null)
        {
            throw new NotImplementedException();
        }

        public Task<ActionsResult> Op_13(ActionsProcedure model = null)
        {
            throw new NotImplementedException();
        }

        public Task<ActionsResult> Op_14(ActionsProcedure model = null)
        {
            throw new NotImplementedException();
        }

        public Task<ActionsResult> Op_15(ActionsProcedure model = null)
        {
            throw new NotImplementedException();
        }
    }
}
