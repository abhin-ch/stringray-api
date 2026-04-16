# StingrayNET.Application

Service layer. Contains complex business logic for PCC and TOQ modules, workflow state machines, email orchestration, and the background task worker. References ApplicationCore and Infrastructure.

## Services

| Class | Lifetime | Purpose |
|-------|----------|---------|
| `PCCService` | Scoped | PCC (Budgeting) orchestration: status options, tab visibility, PBRF/SDQ/DVN status updates, PDF report (29 concurrent SP calls), email dispatch |
| `TOQService` | Scoped | TOQ orchestration: status options, vendor-filtered data fetch |
| `PCCStatusProvider` | Scoped | Builds state machine of valid next statuses for PCC records |
| `TOQStatusProvider` | Scoped | Builds state machine for TOQ records, dispatches to type-specific status classes |
| `PCCHelperFunctions` | Scoped | Shared PCC utilities (user role lookup) |
| `TOQHelperFunctions` | Scoped | Shared TOQ utilities |
| `AdminHelperFunctions` | Scoped | User details, access request emails |
| `BaseEmailService` | Singleton | Queues email builds to `IBackgroundTaskQueue` — decouples email from request lifecycle |
| `BackgroundTaskQueue` | Singleton | `Channel<Func<CancellationToken,Task>>`, capacity 100, backpressure mode |
| `STNGBackgroundWorker` | Hosted | Drains BackgroundTaskQueue in continuous loop. All emails sent here. |
| `PCCSingletonService` | Singleton | Builds PCC email HTML (PBRF/SDQ/DVN deep links, SM approval lists) and sends via BaseEmailService |
| `TOQSingletonService` | Singleton | Builds TOQ email HTML (deliverable tables, 15+ email types) |
| `AdminSingletonService` | Singleton | Sends access request emails |
| `MetricEmails` | Scoped | Metric report emails |
| `DevOpsService` | Scoped | Wraps Infrastructure's IDevopsService for feedback → Azure DevOps work items |

## Workflow State Machine

Located in `Modules/PCC/Status/` and `Modules/TOQ/Status/`.

`BaseStatus<T>` subclasses define valid state transitions per record type and user role:

**PCC:** `StatusSDQ`, `StatusPBRF`, `StatusDVN`
**TOQ:** `StatusTOQStandard`, `StatusTOQEmergent`, `StatusTOQRework`, `StatusTOQConsulting`, `StatusTOQSVN`

Each `NextStatus(row)` checks `UserRole.IsTOQAdmin`, `.IsPCCAdmin`, `.IsSysAdmin`, `.IsVendor`, `.BPRoles` to determine allowed transitions.

## Validation

Located in `Modules/PCC/Validation/`:
- `ValidationPBRF.IsHeaderValid` — PBRF header field validation
- `ValidationSDQ` — SDQ-specific rules
- `ValidationDVN` — DVN-specific rules
- `SDQFundingAllocationValidator` — funding allocation business rules

## DI Registration

`Extensions/ModuleServiceExtensions.cs` → `AddApplicationServices()`:
- Scoped: PCCService, TOQService, status/helper providers, MetricEmails, DevOpsService
- Singleton: PCCSingletonService, TOQSingletonService, AdminSingletonService, BaseEmailService, BackgroundTaskQueue
- Hosted: STNGBackgroundWorker

## Watch Out For

- **Email environment deep-link logic is duplicated 3 times** — PCCSingletonService, TOQSingletonService, AdminSingletonService all contain identical env-detection blocks. If you change one, change all three.
- **`GetTabVisibility` is incomplete** — all case branches are empty `break`, always returns `false`. Dead code.
- **`PCCService.GetUIAccess`** calls `Op_49` but never uses the result. Dead code.
- **`TOQService.GetVendorAssignedValidate`** throws `NotImplementedException`.
- **`BackgroundTaskQueue` and `STNGBackgroundWorker`** are declared without namespaces (file-level classes) — inconsistent but functional.
- **Singleton services hold scoped dependencies** — the singleton email services receive `IServiceProvider` and create scopes manually. Don't inject scoped services directly.
