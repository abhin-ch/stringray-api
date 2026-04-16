# Scripts

Support scripts: SQL schema definitions, ETL pipelines, email templates, Azure deployment, and document templates.

## Directory Structure

```
Scripts/
  SQL/
    DED/              ← Design Engineering database objects
    SC/               ← Supply Chain / core application database objects
  ETL/                ← PowerShell ETL scripts (P6 → SQL Server)
  Azure/              ← Deployment and NuGet update scripts
  EmailTemplate/      ← HTML email templates with [placeholder] syntax
  CSQTemplates/       ← Word document templates for CSQ reports
  HabibTemp/          ← Temporary SQL scripts (user management data)
```

## SQL/ — Database Schema

### Two databases: DED and SC

Both share the same internal structure: `Stored Procedure/`, `Function/`, `Table/`, `View/`, `Trigger/`, `Type/`.

**Schemas:** `stng` (primary), `stngQA` (QA mirror), `stngetl` (ETL staging), `temp` (transient)

**Key pattern:** Each module has ONE stored procedure (`stng.SP_XXX_CRUD`) with `@Operation TINYINT` dispatch. All parameters default to NULL.

### Major Modules (by table/SP count)

| Module | Tables | Key SP | Description |
|--------|--------|--------|-------------|
| CARLA | Fragnet, FragnetActivity, ChangeLog, CommitmentDate, ScopeSelection | SP_CARLA_CRUD | Schedule tracking from P6 |
| TOQ | TOQ_Main + 25 tables, TOQLite_* tables | SP_TOQ_CRUD | Vendor quotation workflow |
| Budgeting/PCC | Budgeting_SDQ* + 40 tables | SP_Budgeting_CRUD, SP_Budgeting_SDQ | Budget lifecycle (SDQ/PBRF/DVN) |
| ER | ER_Main + 15 tables | SP_ER_CRUD | Engineering reviews |
| Metric | Metric_Main + 12 tables | SP_Metric_CRUD | KPI dashboards |
| SST | SST_Main + 10 tables | SP_SST_CRUD | Skilled trades scope |
| CMDS | CMDS_Action + 10 tables | SP_CMDS_CRUD | Commitment dashboard |
| GovernTree | 15+ tables | SP_GovernTree_CRUD | Governance hierarchy |
| Admin | Admin_User/Role/AppSecurity + 10 tables | SP_Admin_UserManagement | RBAC with recursive role CTEs |
| MPL | MPL table | SP_MPL_CRUD | Master project list |

### SQL Conventions
- Views prefixed `VV_` (not `V_`)
- Audit columns: `RAD`/`RAB` (Record Add Date/By)
- User FK: `EmployeeID` (varchar)
- Lookups: `Common_ValueLabel` (uniqueidentifier FK)
- `stng.[GetDate]()` custom function instead of `GETDATE()`
- SP template: `Scripts/SQL/DED/Stored Procedure/_TEMPLATE.sql`

## ETL/ — PowerShell Data Pipelines

All connect to SQL Server `LSN_BE_D,1569` (database `ENG_STG`) using Windows Integrated Auth. Source P6 data: `LSN_PSTG001,1572` → `P6_DV`.

| Script | Schedule | What it does |
|--------|----------|-------------|
| `Stingray_P6CARLA.ps1` | Nightly | Full reload: P6 projects → `stng.Fragnet` + `stng.FragnetActivity`, imports MPL, runs CARLA-Importer.exe, generates Gantt charts |
| `Stingray_P6CARLA_QA.ps1` | Nightly | Same as above but targets `stngQA` schema |
| `Stingray_P6Project.ps1` | On-demand | Targeted refresh for specific project list (passed as arg) |
| `StingrayImportMPL.ps1` | Called by P6CARLA | Imports MPL from Excel on `\\corp.brucepower.com\common$\...\MPL\` |
| `GanttChartETL.ps1` | Called by P6CARLA | Generates Gantt Chart Excel via VBA macro template |

Error handling: logs to `stng.ActionLog` + `stng.ETLLog`, sends email via `msdb.dbo.sp_send_dbmail`.

## EmailTemplate/ — HTML Email Templates

All use `[placeholder]` syntax replaced server-side by C# `Template` class. Some also use `<!--key-->` HTML comment injection points for dynamic table rows.

| Template | Trigger |
|----------|---------|
| ETDBCancelled.html | TDS status → Cancelled |
| ETDBComplete.html | TDS status → Complete |
| ETDBIssues.html | TDS flagged with issues |
| ETDBTempusPick.html | Tempus pick needed |
| MPLChange.html | MPL personnel change |
| ScheduleUpdate.html | Schedule adjustment request |
| ScheduleUpdateNCSQ.html | NCSQ push request needing PCS Lead approval |

## Azure/ — Deployment Scripts

- `PublishContainers.ps1` — Manual Docker build + push to ACR + App Service restart. Hardcoded Azure subscription IDs, resource groups, ACR names. Developer-machine-specific paths (`C:\Users\612497\...`).
- `APIPackageUpdate.ps1` — Bulk NuGet package updater. Exempts EPPlus, pins specific auth package versions.
- Both `.bat` files are just PowerShell launchers.

## CSQTemplates/ — Word Documents

4 `.docx` templates for CSQ (Commitment Scoping Quotation) reports:
- With/without Class V (nuclear QA classification)
- New/Revision variants

Generated or downloaded from the CARLA module when users create CSQ documents.
