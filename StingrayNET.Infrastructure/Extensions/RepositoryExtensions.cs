

using Microsoft.Extensions.DependencyInjection;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.Infrastructure.Repository;
using StingrayNET.Infrastructure.Repository.Modules;
using Models = StingrayNET.ApplicationCore.Models;


namespace StingrayNET.Infrastructure.Extensions;

public static class RepositoryExtensions
{
    public static IServiceCollection AddModuleRepository(this IServiceCollection services)
    {
        services.AddScoped<IRepositoryXL<Models.CARLA.CARLAProcedure, Models.CARLA.CARLAResult>, CARLARepository>();
        services.AddScoped<IRepositoryS<Models.Common.NotificationProcedure, Models.Common.NotificationResult>, NotificationRepository>();
        services.AddScoped<IRepositoryS<Models.Common.Procedure, Models.ALR.ALRResult>, ALRRepository>();
        services.AddScoped<IRepositoryS<Models.Common.Procedure, Models.TableLayout.TableLayoutResult>, TableLayoutRepository>();
        services.AddScoped<IRepositoryXL<Models.Admin.AdminProcedure, Models.Admin.AdminResult>, AdminRepository>();
        services.AddScoped<IRepositoryS<Models.Admin.AdminTempProcedure, Models.Admin.AdminResult>, AdminTempRepository>();
        services.AddScoped<IRepositoryS<Models.Escalations.EscalationProcedure, Models.Escalations.EscalationResult>, EscalationRepository>();
        services.AddScoped<IRepositoryL<Models.MPL.MPLProcedure, Models.MPL.MPLResult>, MPLRepository>();
        services.AddScoped<IRepositoryS<Models.Actions.ActionsProcedure, Models.Actions.ActionsResult>, ActionRepository>();
        services.AddScoped<IRepositoryL<Models.MCREDVN.MCREDVNProcedure, Models.MCREDVN.MCREDVNResult>, MCREDVNRepository>();
        services.AddScoped<IRepositoryM<Models.ETDB.ETDBProcedure, Models.ETDB.ETDBResult>, ETDBRepository>();
        services.AddScoped<IRepositoryM<Models.IQT.IQTProcedure, Models.IQT.IQTResult>, IQTRepository>();
        services.AddScoped<IRepositoryM<Models.CSA.CSAProcedure, Models.CSA.CSAResult>, CSARepository>();
        services.AddScoped<IRepositoryM<Models.PR.PRProcedure, Models.PR.PRResult>, PRRepository>();
        services.AddScoped<IRepositoryXL<Models.TOQLite.TOQLiteProcedure, Models.TOQLite.TOQLiteResult>, TOQLiteRepository>();
        services.AddScoped<IRepositoryL<Models.SST.SSTProcedure, Models.SST.SSTResult>, SSTRepository>();
        services.AddScoped<IRepositoryXL<Models.Governtree.GoverntreeProcedure, Models.Governtree.GoverntreeResult>, GoverntreeRepository>();
        services.AddScoped<IRepositoryXL<Models.Metric.MetricProcedure, Models.Metric.MetricResult>, MetricRepository>();
        services.AddScoped<IRepositoryL<Models.CMDS.CMDSProcedure, Models.CMDS.CMDSResult>, CMDSRepository>();
        services.AddScoped<IRepositoryM<Models.EQDB.EQDBProcedure, Models.EQDB.EQDBResult>, EQDBRepository>();
        services.AddScoped<IRepositoryXL<Models.ER.ERProcedure, Models.ER.ERResult>, ERRepository>();
        services.AddScoped<IRepositoryL<Models.EI.EIProcedure, Models.EI.EIResult>, EIRepository>();
        services.AddScoped<IRepositoryXL<Models.PCC.PCCProcedure, Models.PCC.PCCResult>, BudgetingRepository>();
        services.AddScoped<IRepositoryS<Models.StandardComp.StandardCompProcedure, Models.StandardComp.StandardCompResult>, StandardCompRepository>();
        services.AddScoped<IRepositoryS<Models.Common.Procedure, Models.Catalog.CatalogResult>, CatalogRepository>();
        services.AddScoped<IRepositoryS<Models.Common.Procedure, Models.Comment.CommentResult>, CommentRepository>();
        services.AddScoped<IRepositoryS<Models.Feedback.FeedbackProcedure, Models.Feedback.FeedbackResult>, FeedbackRepository>();
        services.AddScoped<IRepositoryS<Models.SORT.SORTProcedure, Models.SORT.SORTResult>, SORTRepository>();
        services.AddScoped<IRepositoryM<Models.Common.Procedure, Models.Common.CommonResult>, CommonRepository>();
        services.AddScoped<IRepositoryM<Models.Common.Procedure, Models.Admin.DelegateResult>, DelegateRepository>();
        services.AddScoped<IRepositoryL<Models.Common.Procedure, Models.TOQ.TOQResult>, TOQRepository>();
        services.AddScoped<IRepositoryL<Models.TWP.TWPProcedure, Models.TWP.TWPResult>, TWPRepository>();
        services.AddScoped<IRepositoryM<Models.VDU.VDUProcedure, Models.VDU.VDUResult>, VDURepository>();
        services.AddScoped<IRepositoryL<Models.DWMS.DWMSProcedure, Models.DWMS.DWMSResult>, DWMSRepository>();
        services.AddScoped<IRepositoryS<Models.Plugin.PluginProcedure, Models.Plugin.PluginResult>, PluginRepository>();
        services.AddScoped<IRepositoryL<Models.ECRA.ECRAProcedure, Models.ECRA.ECRAResult>, ECRARepository>();
        services.AddScoped<IRepositoryS<Models.Common.Procedure, Models.STMS.STMSResult>, STMSRepository>();
        return services;
    }
}