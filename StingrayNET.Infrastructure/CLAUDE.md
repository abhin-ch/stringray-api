# StingrayNET.Infrastructure

All I/O lives here. Raw ADO.NET SQL access, Azure services (Blob, Key Vault, ADF, Graph, DevOps), caching, WebSocket, expression engine, Excel export.

## Core Data Access: MSSQL<T>

`Services/MSSQL.cs` — implements `IDatabase<T>`. **No EF Core, no Dapper. Raw ADO.NET only.**

Each call creates a new `SqlConnection` (relies on ADO.NET connection pooling). All SQL is `CommandType.StoredProcedure`.

| Method | What it does |
|--------|-------------|
| `ExecuteReaderSetAsync` | Multiple result sets → `IReadOnlyDictionary<int, List<object>>` (up to 4 sets). Timeout: 300s |
| `ExecuteReaderAsync` | Single result set → `List<object>`. Timeout: 120s |
| `ExecuteNonQueryAsync` | INSERT/UPDATE/DELETE |
| `ExecuteNonQueryAsyncReturn` | Captures OUTPUT parameters |
| `ExecuteReaderDTAsync` | Single result set → `DataTable` |
| `BulkInsertAsync` | `SqlBulkCopy` with auto column mapping |

All rows materialize as `Dictionary<string, object>` (column name → value). `DBNull` → empty string `""`.

## Repository Pattern

Every `XxxRepository : BaseRepository<XxxResult>`:
```csharp
protected override string Query => "stng.SP_XXX_CRUD";
public async Task<XxxResult> Op_01(XxxProcedure model = null) => await ExecuteReader<SC>(1, model);
```

The `operation` int maps to `@Operation` in the stored procedure. `BaseRepository` handles parameter building via `BaseProcedure.GetParameters()` (reflection-based).

**Notable repositories:**
- `AdminRepository` — most complex, batch operations with accumulated validation errors
- `CommonRepository` — **Op_03 is a no-op** (endpoint auto-scanner writes nothing), Op_21-28 throw `NotImplementedException`
- `CARLARepository` — 42+ operations, schedule management

## Azure Services

| Service | Tech | Purpose |
|---------|------|---------|
| `KVService` | Azure.Security.KeyVault.Secrets | **Synchronous** `GetSecret` with 5-retry exponential backoff (max 16s). Blocks thread pool. |
| `IdentityService` | SQL + IMemoryCache | Resolves Azure AD principal → internal `User` via `SP_Admin_UserManagement Op=25`. Caches per username. `SemaphoreSlim(1)` for concurrent access. Handles impersonation. |
| `EmailService` | Microsoft.Graph | Sends via Graph API (`/users/{email}/sendMail`). Non-prod: redirects all email to sender with disclaimer. Produces `.msg` via MsgKit. HTML injection via `<!--key-->` comment placeholders. |
| `BLOBService` | Azure.Storage.Blobs | Chunked upload: start → chunk → end (stage blocks, commit, set metadata). Paths: `temp/{module}/{uuid}/{id}` → `prod/{module}/{uuid}`. |
| `ADFService` | Azure.Management.DataFactory | Trigger ADF pipelines by name, poll run status. Can target override production factory. |
| `DevopsService` | TeamFoundationServer.Client | Creates Azure DevOps work items via REST patch documents + attachments |
| `CacheProvider` | IMemoryCache | Default 15 min TTL. Supports `Clear` (casts to MemoryCache). |
| `WSService` | WebSockets + JWT | Issues ephemeral JWT for WS upgrade (stored via `SP_Admin_EphemeralToken`). Sends `SequentialSchema` on connect. Signing key from Key Vault. |
| `ExpressionSerializer` | Custom parser | Parses SQL-like expression language: `[dataset].[field]`, operators, `Every()`/`Any()` functions. Evaluates against in-memory data. Used for dynamic authorization rules. **No logging.** |
| `ExcelService` | EPPlus 4.5.3.3 | `List<object>` → multi-sheet `.xlsx` from `ExcelConvertRequest` config |

## DI Registration

`Extensions/InfrastructureServiceExtensions.cs`:
- `AddAzureServices()` — all Azure service singletons/scoped
- `AddDatabaseServers()` — `IDatabase<SC>` and `IDatabase<DED>` as Scoped

`Extensions/RepositoryExtensions.cs`:
- `AddModuleRepository()` — ~35 scoped repositories

## Watch Out For

- **`KVService.GetSecret` is synchronous** — blocks the thread pool. Every email send, ADF trigger, or token operation hits this.
- **`IdentityService` uses `SemaphoreSlim(1)`** — serializes user lookups per instance. Separate from the middleware's static semaphore.
- **`EmailService` non-prod redirect** — in Development/QA, all emails go to the sender address with a "REDIRECTED" disclaimer. Production sends to actual recipients.
- **`MSSQL<T>` materializes `DBNull` as `""`** — empty strings and NULL are indistinguishable downstream. This is by design but causes subtle bugs if you expect null.
- **`ExpressionSerializer` has no logging** — parse failures throw raw `Exception` with limited context.
- **EPPlus 4.5.3.3** — old version, pre-license-change. Upgrading to 5+ requires a commercial license.
