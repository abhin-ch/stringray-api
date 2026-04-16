# StingrayNET.Api

Web API host project. Entry point, middleware pipeline, 41 controllers, Swagger, auth, CORS, compression.

## Bootstrap (Program.cs)

Monolithic file that configures the entire app. Key registration order:

1. `AddAzureServices()` — KVService, WSService, CacheProvider, IdentityService, BLOBService, EmailService, ADFService, DevopsService
2. `AddModuleRepository()` — ~35 scoped module repositories
3. `AddApplicationServices()` — PCCService, TOQService, status providers, singleton email services, BackgroundTaskQueue, STNGBackgroundWorker
4. `AddDatabaseServers()` — `IDatabase<SC>` and `IDatabase<DED>` (both Scoped)
5. Plus: ExpressionSerializer, ExcelService, NotificationService (all Transient)
6. Azure AD auth via `AddMicrosoftIdentityWebApiAuthentication` with distributed SQL token cache

Middleware pipeline order: ExceptionMiddleware → HSTS → HTTPS redirect → Static files → Routing → CORS → Auth → StingrayAuth → Swagger → Compression → Endpoints

## Controllers

All 41 controllers follow one of two patterns:

**Pattern A (most modules):**
```csharp
[ModuleRoute("api/[controller]", ModuleEnum.XXX)]
public class XXXController : BaseApiController { }
```
`BaseApiController` provides `[Authorize]`, `[EnableCors("stingrayCORS")]`, `[ApiController]`, and `IIdentityService`.

**Pattern B (Admin, File, infrastructure controllers):**
```csharp
[Route("api/[controller]")]
[Authorize]
public class AdminController : ControllerBase { }
```
Note: Pattern B controllers lack `[EnableCors]` and don't participate in endpoint auto-scanning module registration.

**Every action** returns `BaseResult.JsonResult(result)` → `JsonResult`. Actions are thin: extract `EmployeeID`, call `repo.Op_XX()`, return result.

## Middleware

| File | Purpose |
|------|---------|
| `CustomMiddleware/ExceptionMiddleware.cs` | Global exception handler. Maps to HTTP codes: 400=BadRequest, 401=Unauthorized, 403=Forbidden, 404=NotFound, 425=Validation, 503=SQL unavailable, 510=SQL error, 520=unhandled, 530=downstream API |
| `CustomMiddleware/StingrayAuthMiddleware.cs` | DB-driven RBAC. Per-request: resolves identity, checks impersonation (`STNG-IMPERSONATE-AS` header), loads allowed endpoints from DB (`Op_48`), verifies `{path}:{verb}` against cached `HashSet<string>` (15 min TTL). **Static `SemaphoreSlim(1)` = global bottleneck.** |

## Other Files

| File | Purpose |
|------|---------|
| `EndPointAutoScanner.cs` | Reflection-based startup scan: finds all controllers, extracts routes/verbs/`[AppSecurity]` attributes, calls `SP_Common_CRUD Op_03` to upsert endpoint + privilege records. **Currently broken: Op_03 is a no-op in CommonRepository.** |
| `LogEventFormatter.cs` | Custom Serilog formatter (key=value pairs). Registered but never used — Serilog configured from appsettings instead. |

## Adding a New Controller

1. Create `XxxController : BaseApiController` with `[ModuleRoute("api/[controller]", ModuleEnum.XXX)]`
2. Inject `IRepositoryXX<XxxProcedure, XxxResult>` via constructor
3. Add action methods that call `repo.Op_XX(procedure)` and return `BaseResult.JsonResult(result)`
4. Add `[AppSecurity("PrivilegeName", "Type")]` attributes for RBAC
5. The endpoint auto-scanner will pick it up on next startup

## Watch Out For

- Changing `[AppSecurity]` attributes changes what the auto-scanner writes to the DB — this affects user permissions
- `AdminController` doesn't extend `BaseApiController` — it has different CORS behavior
- The inline 403 middleware in `Program.cs` (before `StingrayAuthMiddleware`) checks authentication, not authorization — don't confuse the two layers
- `ShowPII = true` is set unconditionally before the environment check — leaks PII in production logs
