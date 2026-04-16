using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StingrayNET.ApplicationCore.Models
{
    /*Module names must exist in stng.Admin_Module.NameShort. This enum is used to map controllers with module names to create endpoint AppSecurity records.*/
    public enum ModuleEnum
    {
        Admin,
        CARLA,
        ETDB,
        ALR,
        VendorRubric,
        Escalations,
        SORT,
        MPL,
        Common,
        IQT,
        StandardComp,
        TOQ,
        CSA,
        Budgeting,
        TOQLite,
        GovernTree,
        Actions,
        SST,
        PR,
        VDU,
        TWP,
        CMDS,
        Notification,
        EQDB,
        MCREDVN,
        ER,
        DWMS,
        Metric,
        EI,
        ECRA
    }
}