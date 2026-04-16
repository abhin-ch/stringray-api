using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.CustomExceptions;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules
{
    public class AdminRepository : BaseRepository<AdminResult>, IRepositoryXL<AdminProcedure, AdminResult>
    {
        protected override string Query => "stng.SP_Admin_UserManagement";
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AdminRepository(IDatabase<SC> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
        {
            _httpContextAccessor = httpContextAccessor;
        }



        public async Task<AdminResult> Op_46(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(46, model);
        }
        public async Task<AdminResult> Op_47(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(47, model);
        }
        public Task<AdminResult> Op_48(AdminProcedure model = null)
        {
            return ExecuteReaderValidation<SC>(48, model);
        }
        public Task<AdminResult> Op_49(AdminProcedure model = null)
        {
            throw new NotImplementedException();
        }
        public async Task<AdminResult> Op_50(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(50, model);
        }
        public async Task<AdminResult> Op_51(AdminProcedure model = null)
        {
            //Get Employee ID
            model = new AdminProcedure() { EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString() };

            return await ExecuteReader<SC>(25, model);
        }
        public async Task<AdminResult> Op_52(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(52, model);
        }
        //create access request
        public async Task<AdminResult> Op_53(AdminProcedure model = null)
        {
            // model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(53, model);
        }
        //read access request
        public async Task<AdminResult> Op_54(AdminProcedure model = null)
        {
            model = new AdminProcedure();
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(54, model);
            //simple get request, take EID and return all requests they have permission to manage
        }

        //update access request
        public async Task<AdminResult> Op_55(AdminProcedure model = null)
        {
            // model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(55, model);
        }
        public async Task<AdminResult> Op_56(AdminProcedure model = null)
        {
            if (model == null)
            {
                model = new AdminProcedure();
            }


            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(56, model);
        }
        public async Task<AdminResult> Op_57(AdminProcedure model = null)
        {
            if (model == null)
            {
                model = new AdminProcedure();
            }


            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(57, model);
        }
        public async Task<AdminResult> Op_58(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(58, model);
        }
        public async Task<AdminResult> Op_59(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(59, model);
        }
        public async Task<AdminResult> Op_60(AdminProcedure model = null)
        {

            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(60, model);
        }

        public async Task<AdminResult> Op_61(AdminProcedure model = null)
        {

            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(61, model);
        }
        public async Task<AdminResult> Op_62(AdminProcedure model = null)
        {
            return await ExecuteReader<SC>(62, model);
        }
        public async Task<AdminResult> Op_63(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(63, model);
        }
        public async Task<AdminResult> Op_64(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(64, model);
        }
        public async Task<AdminResult> Op_65(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(65, model);
        }

        //read access request aggregated status
        public async Task<AdminResult> Op_66(AdminProcedure model = null)
        {
            model = new AdminProcedure();
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(66, model);
            //simple get request, take EID and return all requests they have permission to manage
        }

        public async Task<AdminResult> Op_67(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(67, model);
        }
        public async Task<AdminResult> Op_68(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(68, model);
        }
        public async Task<AdminResult> Op_69(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(69, model);
        }
        public async Task<AdminResult> Op_70(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(70, model);
        }
        public async Task<AdminResult> Op_71(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.RoleArgs?.Count == 0 || model.RoleArgs?.Count == null)
            {
                throw new ValidationException(@"RoleArgs are required");
            }

            foreach (RoleArg roleArg in model.RoleArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    SubRequestID = model.SubRequestID,
                    RoleID = roleArg.RoleID,
                    Role = roleArg.Role,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(71, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of RoleArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }
        public async Task<AdminResult> Op_72(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(72, model);
        }
        public async Task<AdminResult> Op_73(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(73, model);
        }
        public async Task<AdminResult> Op_74(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(74, model);
        }
        public async Task<AdminResult> Op_75(AdminProcedure model = null)
        {
            if (model == null)
            {
                model = new AdminProcedure();
            }

            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(75, model);
        }
        public async Task<AdminResult> Op_76(AdminProcedure model = null)
        {
            model = new AdminProcedure();

            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(76, model);
        }
        public async Task<AdminResult> Op_77(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(77, model);
        }
        public async Task<AdminResult> Op_78(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(78, model);
        }
        public async Task<AdminResult> Op_79(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(79, model);
        }
        public async Task<AdminResult> Op_80(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.PermissionArgs?.Count == 0 || model.PermissionArgs?.Count == null)
            {
                throw new ValidationException(@"Work Groups are required");
            }

            foreach (PermissionArg permissionArg in model.PermissionArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    RoleID = model.RoleID,

                    PermissionID = permissionArg.PermissionID,

                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(80, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of PermissionArg - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }
        public async Task<AdminResult> Op_81(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(81, model);
        }
        public async Task<AdminResult> Op_82(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(82, model);
        }
        public async Task<AdminResult> Op_83(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(83, model);
        }
        public async Task<AdminResult> Op_84(AdminProcedure model = null)
        {
            model.EmployeeID = this._httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(84, model);
        }
        public async Task<AdminResult> Op_85(AdminProcedure model = null)
        {
            model.EmployeeID = this._httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(85, model);
        }
        public async Task<AdminResult> Op_86(AdminProcedure model = null)
        {
            model.EmployeeID = this._httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(86, model);
        }
        public async Task<AdminResult> Op_87(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(87, model);
        }
        public Task<AdminResult> Op_88(AdminProcedure model = null)
        {
            throw new NotImplementedException();
        }
        public Task<AdminResult> Op_89(AdminProcedure model = null)
        {
            throw new NotImplementedException();
        }
        public Task<AdminResult> Op_90(AdminProcedure model = null)
        {
            throw new NotImplementedException();
        }

        public async Task<AdminResult> Op_45(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.PermissionArgs?.Count == 0 || model.PermissionArgs?.Count == null)
            {
                throw new ValidationException(@"PermissionArgs are required");
            }

            foreach (PermissionArg permissionArg in model.PermissionArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    EndpointID = model.EndpointID,
                    Endpoint = model.Endpoint,
                    HTTPVerb = model.HTTPVerb,
                    PermissionID = permissionArg.PermissionID,
                    Permission = permissionArg.Permission,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(45, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of PermissionArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_44(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(44, model);
        }

        public async Task<AdminResult> Op_43(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(43, model);
        }

        public async Task<AdminResult> Op_42(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.AttributeArgs?.Count == 0 || model.AttributeArgs?.Count == null)
            {
                throw new ValidationException(@"AttributeArgs are required");
            }

            foreach (AttributeArg attributeArg in model.AttributeArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    EndpointID = model.EndpointID,
                    Endpoint = model.Endpoint,
                    HTTPVerb = model.HTTPVerb,
                    AttributeID = attributeArg.AttributeID,
                    Attribute = attributeArg.Attribute,
                    AttributeType = attributeArg.AttributeType,
                    AttributeTypeID = attributeArg.AttributeTypeID,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(42, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of AttributeArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_41(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(41, model);
        }

        public async Task<AdminResult> Op_40(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(40, model);
        }

        public async Task<AdminResult> Op_39(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(39, model);
        }

        public async Task<AdminResult> Op_38(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(38, model);
        }

        public async Task<AdminResult> Op_37(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(37, model);
        }

        public async Task<AdminResult> Op_36(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(36, model);
        }

        public async Task<AdminResult> Op_35(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(35, model);
        }

        public async Task<AdminResult> Op_34(AdminProcedure model = null)
        {
            if (model == null)
            {
                //Current user roles
                return await ExecuteReaderValidation<SC>(34, new AdminProcedure()
                {
                    EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
                });

            }

            else
            {
                return await ExecuteReaderValidation<SC>(34, model);
            }
        }

        public async Task<AdminResult> Op_33(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(33, model);
        }

        public async Task<AdminResult> Op_32(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.RoleArgs?.Count == 0 || model.RoleArgs?.Count == null)
            {
                throw new ValidationException(@"RoleArgs are required");
            }

            foreach (RoleArg roleArg in model.RoleArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    EmployeeIDInsert = model.EmployeeIDInsert,
                    RoleID = roleArg.RoleID,
                    Role = roleArg.Role,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(32, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of RoleArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_31(AdminProcedure model = null)
        {
            if (string.IsNullOrEmpty(model.EmployeeID))
            {
                model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"]?.ToString();
            }
            return await ExecuteReaderValidation<SC>(31, model);
        }

        public async Task<AdminResult> Op_30(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(30, model);
        }

        public async Task<AdminResult> Op_29(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.PermissionArgs?.Count == 0 || model.PermissionArgs?.Count == null)
            {
                throw new ValidationException(@"PermissionArgs are required");
            }

            foreach (PermissionArg permissionArg in model.PermissionArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    EmployeeIDInsert = model.EmployeeIDInsert,
                    PermissionID = permissionArg.PermissionID,
                    Permission = permissionArg.Permission,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(29, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of PermissionArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_28(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(28, model);
        }

        public async Task<AdminResult> Op_27(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(27, model);
        }

        public async Task<AdminResult> Op_26(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();


            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.AttributeArgs?.Count == 0 || model.AttributeArgs?.Count == null)
            {
                throw new ValidationException(@"AttributeArgs are required");
            }

            foreach (AttributeArg attributeArg in model.AttributeArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    EmployeeIDInsert = model.EmployeeIDInsert,
                    AttributeID = attributeArg.AttributeID,
                    Attribute = attributeArg.Attribute,
                    AttributeType = attributeArg.AttributeType,
                    AttributeTypeID = attributeArg.AttributeTypeID,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(26, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of AttributeArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_25(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(25, model);
        }

        public async Task<AdminResult> Op_24(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(24, model);
        }

        public async Task<AdminResult> Op_23(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(23, model);
        }

        public async Task<AdminResult> Op_22(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.PermissionArgs?.Count == 0 || model.PermissionArgs?.Count == null)
            {
                throw new ValidationException(@"PermissionArgs are required");
            }

            foreach (PermissionArg permissionArg in model.PermissionArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    RoleID = model.RoleID,
                    Role = model.Role,
                    PermissionID = permissionArg.PermissionID,
                    Permission = permissionArg.Permission,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(22, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of PermissionArg - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_21(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(21, model);
        }

        public async Task<AdminResult> Op_20(AdminProcedure model = null)
        {
            throw new NotImplementedException();
        }

        public async Task<AdminResult> Op_19(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.AttributeArgs?.Count == 0 || model.AttributeArgs?.Count == null)
            {
                throw new ValidationException(@"AttributeArgs are required");
            }

            foreach (AttributeArg attributeArg in model.AttributeArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    RoleID = model.RoleID,
                    Role = model.Role,
                    AttributeID = attributeArg.AttributeID,
                    Attribute = attributeArg.Attribute,
                    AttributeType = attributeArg.AttributeType,
                    AttributeTypeID = attributeArg.AttributeTypeID,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(19, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of AttributeArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_18(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(18, model);
        }

        public async Task<AdminResult> Op_17(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(17, model);
        }

        public async Task<AdminResult> Op_16(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(16, model);
        }

        public async Task<AdminResult> Op_15(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(15, model);
        }

        public async Task<AdminResult> Op_14(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(14, model);
        }

        public async Task<AdminResult> Op_13(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(13, model);
        }

        public async Task<AdminResult> Op_12(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.PermissionArgs?.Count == 0 || model.PermissionArgs?.Count == null)
            {
                throw new ValidationException(@"PermissionArgs are required");
            }

            foreach (PermissionArg permissionArg in model.PermissionArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    ParentPermission = model.ParentPermission,
                    PermissionID = permissionArg.PermissionID,
                    Permission = permissionArg.Permission,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(12, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of PermissionArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_11(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(11, model);
        }

        public async Task<AdminResult> Op_10(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(10, model);
        }

        public async Task<AdminResult> Op_09(AdminProcedure model = null)
        {
            var empID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

            List<string> validationExceptions = new List<string>();
            int counter = 0;

            if (model.AttributeArgs?.Count == 0 || model.AttributeArgs?.Count == null)
            {
                throw new ValidationException(@"AttributeArgs are required");
            }

            foreach (AttributeArg attributeArg in model.AttributeArgs)
            {
                AdminProcedure loopModel = new AdminProcedure()
                {
                    PermissionID = model.PermissionID,
                    Permission = model.Permission,
                    AttributeID = attributeArg.AttributeID,
                    Attribute = attributeArg.Attribute,
                    AttributeType = attributeArg.AttributeType,
                    AttributeTypeID = attributeArg.AttributeTypeID,
                    EmployeeID = empID
                };

                var response = await ExecuteReaderValidation<SC>(09, loopModel, throwValidationException: false);

                if (response is BaseOperation)
                {
                    BaseOperation returnReaderCast = response;

                    if (returnReaderCast.Data1.Count > 0)
                    {
                        Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                        if (returnReaderData.ContainsKey(@"ReturnMessage"))
                        {
                            validationExceptions.Add($"Validation error at Index {counter} of AttributeArgs - {returnReaderData[@"ReturnMessage"].ToString()}");
                        }
                    }
                }

                counter++;

            }

            if (validationExceptions.Count > 0)
            {
                throw new ValidationException(@"Several validation exceptions. See SupplementaryMessages", validationExceptions);
            }

            return new AdminResult();
        }

        public async Task<AdminResult> Op_08(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(8, model);
        }

        public async Task<AdminResult> Op_07(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(7, model);
        }

        public async Task<AdminResult> Op_06(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(6, model);
        }

        public async Task<AdminResult> Op_05(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(5, model);
        }

        public async Task<AdminResult> Op_04(AdminProcedure model = null)
        {
            return await ExecuteReaderValidation<SC>(4, model);
        }

        public async Task<AdminResult> Op_03(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(3, model);
        }

        public async Task<AdminResult> Op_02(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(2, model);
        }

        public async Task<AdminResult> Op_01(AdminProcedure model = null)
        {
            model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
            return await ExecuteReaderValidation<SC>(1, model);
        }

    }
}
