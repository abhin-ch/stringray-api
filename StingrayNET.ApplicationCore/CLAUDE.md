# StingrayNET.ApplicationCore

Domain layer. Zero external service dependencies. Contains all abstractions, interfaces, models, enums, helper functions, and custom exceptions shared across the solution.

## Abstractions (the framework)

| Class | Purpose |
|-------|---------|
| `BaseProcedure` | Universal stored procedure parameter bag. Properties: Value1-13, Num1-3, Decimal1-3, Date1-5, IsTrue1-5, SubOp, EmployeeID. `GetParameters(operation)` uses **reflection** to auto-map properties to `SqlParameter[]`, including `SqlDbType.Structured` for `List<>` types (converts to `DataTable`). `[StoredProcIgnore]` skips properties. |
| `BaseRepository<K>` | Generic base for all repositories. Holds `IDatabase<SC>` + `IDatabase<DED>`. Key methods: `ExecuteReader<D>`, `ExecuteNonQuery<D>`, `ExecuteReaderValidation<D>` (inspects `ReturnMessage`/`ReturnMessageUnauthorized` in first result row to throw validation/auth exceptions). The `D` type parameter (`SC` or `DED`) routes to the correct database. |
| `BaseOperation` / `BaseOperation<T>` | Return container: `Data1-Data4: List<object>`, `RowsAffected`. Typed variants for strong typing. |
| `BaseResult` | Extends `JsonResult`. Factory: `JsonResult<T>(result)` → `HttpSuccess` or `HttpError`. All controllers use this. **Default constructor throws `NotImplementedException`**. |
| `BaseStatus<T>` | Abstract state machine node for workflows. `Options: List<BaseStatus<T>>`, `StatusCode: DEDStatusEnum`. `NextStatus(row)` populates valid transitions. |
| `BaseDEDModel` | Abstract record model: `StatusCode`, `User: UserRole`, abstract `IsAdmin` and `Type`. |
| `BaseDB` | Holds `_connectionString`, parent for DB-bound classes. |
| `BaseTableType` | Marker abstract for SQL structured table types. |

## Interfaces

**Repository tiers** (each extends the previous):
- `IRepositoryS<T,K>` — Op_01 to Op_15
- `IRepositoryM<T,K>` — adds Op_16 to Op_30
- `IRepositoryL<T,K>` — adds Op_31 to Op_45
- `IRepositoryXL<T,K>` — adds Op_46 to Op_90

**Service interfaces**: `IDatabase<K>`, `IIdentityService`, `ICacheProvider`, `IEmailService`, `IBLOBService`, `IADFService`, `IDevopsService`, `IKVService`, `IWSService`, `IExpressionSerializer`, `INotificationService`, `IBaseEmailService`

## Models

Each business module has a paired set:
- `XxxProcedure : BaseProcedure` — input parameters for the module's stored procedure
- `XxxResult : BaseOperation` — output container

Additional: `ExpressionSerializer/*` (expression tree parser), `ErrorResponse` (exception → HTTP code mapping), `AppSecurityTable`/`EndpointTable` (DataTable subclasses for TVPs).

## Key Specifications

- `SC` / `DED` — empty marker classes implementing `IDepartment`. Used as generic type discriminators for database routing.
- `AppSecurityAttribute` — `[AttributeUsage(Method|Class)]` — tags endpoints with privilege names for RBAC.
- `ModuleRouteAttribute` — extends `RouteAttribute`, adds `ModuleName` from `ModuleEnum`.
- `DEDStatusEnum` — 100+ status codes across PCC (PBRF/SDQ/DVN) and TOQ (Standard/Consulting/Emergent/Rework/SVN) workflows.
- `ModuleEnum` — 29 module names (must match `stng.Admin_Module.NameShort` in the database).

## Helper Functions

| Class | Purpose |
|-------|---------|
| `DataParser` | Extracts typed values from `List<object>` (which are `Dictionary<string,object>` rows): `GetValueFromData<T>`, `GetListFromData<T>`, `GetModelFromObject<T>` (JSON round-trip) |
| `Extensions` | `AddParameter()` for SqlParameter building, `ToDataTable()` for IList→DataTable (TVP), dynamic `Filter()` lambda builder |
| `Template` | String placeholder substitution: `[key]` → value |
| `VDUExcelHelper` / `VDUVerification` | VDU-specific Excel parsing (uses Office Interop — not container-compatible) |

## Watch Out For

- **`BaseProcedure.GetParameters` reflection** — changing property names/types on any `XxxProcedure` silently breaks SQL parameter mapping with no compile-time error
- **`BaseResult()` default constructor throws** — any accidental instantiation causes `NotImplementedException`
- **Office Interop references** — .csproj references `Microsoft.Office.Interop.Excel/Outlook/Word` via local DLL hints. Requires Office installed. Will fail in Docker/Linux.
- **Nullable warnings suppressed** — `NoWarn` includes CS8603, CS8604, CS8618. Real null bugs are masked.
- **`DEDStatusEnum` coupling** — status codes are shared between C# and SQL. Changes must be synchronized.
