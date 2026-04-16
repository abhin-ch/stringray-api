# StingrayNET API

Enterprise ASP.NET Core 8 Web API for Bruce Power's engineering project management platform ("Stingray"). Manages engineering workflows across 29+ business modules including CARLA (schedule tracking), TOQ (vendor quotations), Budgeting/SDQ/PCC, Engineering Reviews, Metrics, and more.

## Architecture

```
StingrayNET.Api/              → Web host, controllers, middleware, auth pipeline
StingrayNET.ApplicationCore/  → Domain layer: abstractions, interfaces, models, enums (NO external deps)
StingrayNET.Application/      → Service layer: PCC/TOQ workflows, email, background worker
StingrayNET.Infrastructure/   → I/O: raw ADO.NET SQL, Azure Blob/KV/ADF/Graph/DevOps services
Scripts/                      → SQL schema, ETL PowerShell, email templates, Azure deploy scripts
Pipelines/                    → Azure DevOps CI/CD (DEV/QA/PROD)
```

**No EF Core. No Dapper.** All database access is raw ADO.NET via `SqlCommand(CommandType.StoredProcedure)`. Each module has ONE stored procedure with an `@Operation TINYINT` dispatch pattern (e.g., `stng.SP_CARLA_CRUD @Operation=1`).

## Two Databases

- **SC** (Supply Chain) — `IDatabase<SC>` — supply chain / procurement data
- **DED** (Design Engineering) — `IDatabase<DED>` — engineering / PMC data

Both are SQL Server on Azure. The C# generic type (`SC` or `DED`) routes queries to the correct connection string. Connection strings come from `appsettings.{Environment}.json` (gitignored — contain Azure AD secrets).

## Key Patterns

### Controller → Repository → Stored Procedure

```
[ModuleRoute("api/[controller]", ModuleEnum.CARLA)]
CARLAController : BaseApiController
  → IRepositoryXL<CARLAProcedure, CARLAResult>
    → ExecuteReader<DED>(operationNumber, procedure)
      → stng.SP_CARLA_CRUD @Operation=N
```

Controllers are thin: set `EmployeeID` from `HttpContext.Items`, call a repo `Op_XX()`, return `BaseResult.JsonResult(result)`. All return `JsonResult`.

### Repository Size Tiers

- `IRepositoryS<T,K>` — Op_01 to Op_15
- `IRepositoryM<T,K>` — extends S, adds Op_16 to Op_30
- `IRepositoryL<T,K>` — extends M, adds Op_31 to Op_45
- `IRepositoryXL<T,K>` — extends L, adds Op_46 to Op_90

### Authentication (3 layers)

1. **Azure AD JWT** — `AddMicrosoftIdentityWebApiAuthentication` validates tokens
2. **Inline 403 middleware** — rejects unauthenticated on non-`[AllowAnonymous]` endpoints
3. **StingrayAuthMiddleware** — DB-driven RBAC: checks `{path}:{verb}` against per-user allowed endpoints (cached 15 min in `IMemoryCache`). Supports impersonation via `STNG-IMPERSONATE-AS` header.

### Endpoint Auto-Scanner

On startup, `EndPointAutoScanner` uses reflection to find all controllers, extract routes/HTTP verbs/`[AppSecurity]` attributes, and upserts them to the `stng` database via `SP_Common_CRUD Op_03`. **Note: Op_03 is currently a no-op (see tech debt).**

### Email via Background Queue

Emails are never sent inline. Singleton services (`PCCSingletonService`, `TOQSingletonService`, `AdminSingletonService`) build email HTML and enqueue via `IBaseEmailService` → `BackgroundTaskQueue` (Channel-based, capacity 100) → `STNGBackgroundWorker` (hosted service) → `IEmailService` (Microsoft Graph API).

### Status Workflow State Machine

PCC and TOQ modules use `BaseStatus<T>` subclasses to define valid state transitions. `NextStatus(row)` inspects the current record + user role and returns allowed next states. Status codes defined in `DEDStatusEnum` (100+ values).

## Build & Run

```bash
dotnet restore StingrayNET.Api/StingrayNET.Api.csproj
dotnet build StingrayNET.Api/StingrayNET.Api.csproj
dotnet run --project StingrayNET.Api
```

Local debugging: VS Code launch config at `.vscode/launch.json` → `https://localhost:7255/`, `ASPNETCORE_ENVIRONMENT=Development`.

Docker: `docker build --build-arg ENVNAME=Development -t stingray-api .`

**Required config:** `appsettings.{Development|QA|Production}.json` with Azure AD credentials, SQL connection strings, Key Vault URI, Blob Storage URI. These are gitignored.

## SQL Schema Conventions

- All objects in `stng` schema (QA mirror: `stngQA`, ETL: `stngetl`)
- Views prefixed `VV_` (not `V_`)
- Audit fields: `RAD` / `RAB` (Record Add Date/By), not `CreatedDate`/`CreatedBy`
- User identity: `EmployeeID` (varchar), not integer PKs
- Lookups: `stng.Common_ValueLabel` (uniqueidentifier FK) — central enum/dropdown table
- Custom `stng.[GetDate]()` function used instead of `GETDATE()` for column defaults

## Environments

| Env | Branch | ACR | App Service |
|-----|--------|-----|-------------|
| DEV | `DEV` | `acrccstingraydev` | `stingraydevapi` |
| QA | `QA` | `acrccstingrayqa` | `stingrayqaapi` |
| PROD | `main` | `acrccstingrayprod` | `stingrayprodapi` |

Pipelines: Azure DevOps (`Pipelines/*.yaml`). Build → Docker push to ACR → `az webapp restart`.

## How to Add a New Module

1. **Domain models** in `ApplicationCore/Models/`: create `XxxProcedure : BaseProcedure` and `XxxResult : BaseOperation`
2. **Repository** in `Infrastructure/Repositories/`: create `XxxRepository : BaseRepository<XxxResult>`, set `Query => "stng.SP_XXX_CRUD"`, implement `Op_XX` methods
3. **Interface** in `ApplicationCore/Interfaces/`: create `IXxxRepository` extending the right tier (`IRepositoryS/M/L/XL`)
4. **Register DI** in `Infrastructure/Extensions/RepositoryExtensions.cs` → `AddModuleRepository()`
5. **Controller** in `Api/Controllers/`: create `XxxController : BaseApiController` with `[ModuleRoute("api/[controller]", ModuleEnum.XXX)]`
6. **Add ModuleEnum** value in `ApplicationCore/Specifications/ModuleEnum.cs` (must match `stng.Admin_Module.NameShort`)
7. **SQL**: create `stng.SP_XXX_CRUD` stored procedure with `@Operation` dispatch, plus tables/views as needed

## Dangerous Zones

- **`StingrayAuthMiddleware`** (`Api/CustomMiddleware/StingrayAuthMiddleware.cs`) — static `SemaphoreSlim(1)` creates a global bottleneck under load. All auth checks serialize through one semaphore.
- **`BaseProcedure.GetParameters`** (`ApplicationCore/Abstractions/BaseProcedure.cs`) — uses reflection to auto-map properties to `SqlParameter`. Changing property names/types silently breaks SQL calls with no compile-time error.
- **`ExceptionMiddleware`** (`Api/CustomMiddleware/ExceptionMiddleware.cs`) — maps exceptions to HTTP codes. Custom codes: 425=Validation, 510=SQL error, 520=unhandled, 530=downstream API. If you add new exception types, map them here.
- **`Program.cs`** (`Api/Program.cs`) — monolithic bootstrap file. DI registration split across 4 extension methods. Order matters for middleware pipeline.
- **`EndPointAutoScanner`** — auto-registers endpoints in the DB. If you change controller routes or `[AppSecurity]` attributes, the DB records update on next startup.
- **`DEDStatusEnum`** — 100+ status codes used across PCC and TOQ workflows. Adding/changing values requires matching DB changes.
- **Environment-specific appsettings** — gitignored (`appsettings.Development/QA/Production.json`). Contain Azure AD secrets, connection strings, Key Vault URIs. Never commit these.

## Known Tech Debt

- `CommonRepository.Op_03` is a no-op — endpoint auto-scanner constructs data but never writes to DB
- `PCCService.GetTabVisibility` — all case branches are empty, always returns `false`
- `ShowPII = true` set unconditionally in `Program.cs` (leaks PII in production)
- Multiple `Op_XX` methods throw `NotImplementedException` (Admin: Op_49/88/89/90; Common: Op_21-28)
- `KVService.GetSecret` is synchronous — blocks thread pool on Azure Key Vault I/O
- `Console.WriteLine` used in production paths (IdentityService, StingrayAuthMiddleware, PCCService)
- Office Interop references in ApplicationCore — requires Office installed, incompatible with Linux/containers
- Nullable reference type warnings suppressed globally (CS8603, CS8604, CS8618)
