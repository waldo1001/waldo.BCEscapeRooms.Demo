# Technical Design Review: Escape Directions Venue

**Source Document:** `EscapeDirections.design.md`  
**Reviewer:** iFacto.SolutionDesigner  
**Date:** March 20, 2026  
**Status:** Approved — Recommendations Applied

---

## 1. Purpose

This document reviews the existing `EscapeDirections.design.md` against the actual BCTalent.EscapeRoom framework source code, identifies issues, and flags decisions that need to be made before implementation.

**Session goal:** 45-minute live-coding walkthrough at Directions, mostly spent in VS Code, building the "Escape Directions" venue from scratch to demonstrate all three validation patterns (polling, event subscriber, test codeunit).

---

## 2. Verification Summary

### Framework Interface Compliance

All 12 AL objects in the design were verified against the framework's actual interface definitions.

| Interface | Methods Required | Design Implements All? | Notes |
|---|---|---|---|
| `iEscapeRoomVenue` | `GetVenueRec`, `GetVenue`, `GetRooms`, `GetRoomCompletedImage`, `GetVenueCompletedImage` | **Yes** | Image methods return empty — framework handles gracefully |
| `iEscapeRoom` | `GetRoomRec`, `GetRoom`, `GetRoomDescription`, `GetTasks`, `Solve` | **Yes** | `Solve()` uses `RichTextBoxPage.Initialize(Caption, HTML)` — signature confirmed |
| `iEscapeRoomTask` | `GetTaskRec`, `GetTask`, `IsValid`, `GetHint` | **Yes** | All 3 task codeunits implement all 4 methods |

### Enum Extension Pattern

| Check | Result |
|---|---|
| Venue enum uses `Implementation = iEscapeRoomVenue = "..."` | **Correct** — matches Dev1, Dev2, OptimAL, Consultant.1 |
| Room enum uses `Implementation = iEscapeRoom = "..."` | **Correct** |
| Task enum uses `Implementation = iEscapeRoomTask = "..."` | **Correct** |
| Enum values implicitly cast to interface in `GetRooms()` | **Correct** — `Rooms.Add(Enum::"Escape Room"::FindYourBadgeED)` works because enum `implements iEscapeRoom` |

### Install Codeunit

| Check | Result |
|---|---|
| Pattern: `EscapeRoom.UpdateVenue(Enum::"Escape Room Venue"::EscapeDirections)` | **Correct** — enum auto-casts to `Interface iEscapeRoomVenue`. Identical to all 4 existing venues. |
| `UpdateVenue` flow: Venue → `Commit` → Rooms (each + `Commit`) → Tasks (each + `Commit`) | **Correct** — verified against Codeunit 73922 source |

### Validation Patterns

| Room | Pattern | Verified Against Framework? | Notes |
|---|---|---|---|
| Room 1 (Polling) | `IsValid()` returns `true` when Company Information Name = `'Directions 2026'` | **Correct** | Stateless, no `SingleInstance` needed |
| Room 2 (Event Subscriber) | `IsValid()` returns `false`; `OnAfterInsertEvent` + `OnAfterModifyEvent` call `SetStatusCompleted()` | **Correct** | `SingleInstance = true`, room status guard, both Insert+Modify — matches `CreateCustomer Dev1` pattern exactly |
| Room 3 (Test Codeunit) | `IsValid()` manages TestQueue manually, runs `TaskValidationTestRunner` | **Correct** | Self-contained pattern, see Decision #3 below |

### Key Framework Methods Verified

| Method | Location | Signature | Design Usage Correct? |
|---|---|---|---|
| `RichTextBoxPage.Initialize` | Page 73929 | `(Caption: Text; HTML: Text)` | **Yes** |
| `GetStatus()` | `"Escape Room"` table | Returns `Enum "Escape Room Status"`, does `Find('=')` | **Yes** |
| `SetStatusCompleted()` | `"Escape Room Task"` table | Calls `Stop()` → `CloseRoomIfCompleted()` | **Yes** |
| `NavApp.GetResourceAsText()` | BC platform | `(ResourceName: Text): Text` | **Yes** — used in all existing venues |
| `NavApp.GetCurrentModuleInfo()` | BC platform | `(var ModuleInfo)` | **Yes** |
| `this` keyword on interface methods | BC 24+ | Allows calling own interface methods | **Yes** — available in BC27 |

### HTML Resource Files

| Check | Result |
|---|---|
| All 6 files follow Description/Solution naming convention | **Yes** |
| No JavaScript, no external CSS, no emoji | **Yes** |
| Description files are mysterious (don't reveal HOW) | **Yes** |
| Solution files provide exact steps | **Yes** |
| Description structure follows 6-section template (H1, TL;DR, Challenge, Mission, Update Status, What's Next) | **Yes** |
| Room 3 Description omits "What's Next" (final room) | **Yes** |

### ID Range

| Venue | Range | Conflict? |
|---|---|---|
| Development.1 | 74000-74099 | — |
| Development.2 | 74100-74199 | — |
| OptimAL.EscapeRoom1 | 74200-74299 | — |
| **EscapeDirections** | **74300-74399** | **No conflict** |
| Consultant.1 | 75000+ | — |

### Object Count

12 AL objects + 6 HTML files. Verified complete — no missing objects for the 3-room, 1-task-per-room design.

---

## 3. Issues Found

### ISSUE 1: BC Version Mismatch ~~(Must Fix)~~ — FIXED

**Severity:** High — won't compile against correct target  
**Resolution:** Applied. Design document updated to `27.0.0.0` for both platform and application.

The design originally specified `26.0.0.0`. Corrected to:
```json
"platform": "27.0.0.0",
"application": "27.0.0.0"
```

Runtime `15.0` is correct for BC27 (confirmed from OptimAL.EscapeRoom1's app.json which targets `application: 27.0.0.0` with `runtime: 15.0`).

### ISSUE 2: Framework Dependency Version ~~— Unclear~~ — FIXED

**Severity:** Medium — could cause install failure if wrong  
**Resolution:** Applied. Design document updated to `1.0.0.0` (safest floor — works with any deployed framework version).

The design originally specified `1.3.0.0`. Changed to `1.0.0.0` because the minimum version in `app.json` is a floor, not a target. Using `1.0.0.0` avoids install failures regardless of which framework version is deployed to the conference environment.

### ISSUE 3: `resourceExposurePolicy` — Intentional?

**Severity:** Low — cosmetic / security stance

The design has:
```json
"resourceExposurePolicy": {
    "allowDebugging": true,
    "allowDownloadingSource": true,
    "includeSourceInSymbolFile": true
}
```

OptimAL.EscapeRoom1 has the opposite:
```json
"resourceExposurePolicy": {
    "allowDebugging": false,
    "allowDownloadingSource": false,
    "includeSourceInSymbolFile": false
}
```

For a demo/educational app this is fine either way. The open policy actually makes sense for a session where you want audience members to be able to read the source. No action needed unless you have a preference.

---

## 4. Decisions — Resolved

### DECISION 1: Framework Dependency Minimum Version — RESOLVED

**Chosen:** Option A — `1.0.0.0`  
**Rationale:** The minimum version is a floor, not a target. Using `1.0.0.0` ensures the app installs regardless of which framework version is deployed to the conference environment. Design document updated.

---

### ~~DECISION 2: Pre-Assign Object IDs or Use Vjeko Live?~~ — REMOVED

Vjeko is the standard workflow for ID assignment. IDs will be assigned via vjeko during session preparation — this is normal practice, not a decision point.

---

### DECISION 3: TestCodeunitId in GetTaskRec() — RESOLVED

The framework's `RefreshTasks` checks:
```al
if TaskRec.TestCodeunitId <> 0 then begin
    if not TestQueue.Get(TaskRec.TestCodeunitId) then begin
        TestQueue."Codeunit Id" := TaskRec.TestCodeunitId;
        TestQueue.Insert();
    end;
end;
```

The design's Room 3 task (`R3T1 Prove You Were Here ED`) does **not** set `TestCodeunitId` in `GetTaskRec()`. Instead, `IsValid()` manually creates the TestQueue record, runs the test, and reads the result.

**Chosen:** Option A — Don't set it (current design).  
**Rationale:** For a teaching demo, having all test orchestration logic visible in `IsValid()` is more valuable than the framework shortcut. The `TestCodeunitId` auto-registration can be mentioned verbally as a "framework also supports this" aside.

---

### DECISION 4: Contact Validation — Company Name vs. Name Field — RESOLVED

**Chosen:** Option A — Keep `"Company Name"` (current design).  
**Rationale:** This is a controlled live demo. The hint says "The company name matters," which guides participants to Company-type contacts. No change needed.

---

## 5. Session Flow Verification

The session outline (9 segments, 45min) was reviewed for logical consistency:

| # | Segment | Minutes | Build Order Correct? | Notes |
|---|---|---|---|---|
| 1 | Intro — show completed venue | 3 | N/A | Requires a **pre-built completed venue** to demo. See note below. |
| 2 | Enum extensions (3 files) | 5 | **Yes** — enums first, before anything that references them | |
| 3 | Venue codeunit | 5 | **Yes** — depends on venue enum | |
| 4 | Room codeunits (3 files) | 5 | **Yes** — depends on room enums | |
| 5 | Task codeunits (3+1 files) | 10 | **Yes** — depends on task enums, room codeunits | Core segment — all 3 patterns |
| 6 | Install codeunit | 3 | **Yes** — depends on venue enum | |
| 7 | HTML resource files | 3 | **Yes** — independent, just need to exist before F5 | |
| 8 | Live demo — play through | 8 | **Yes** — after F5 publish | |
| 9 | Wrap-up | 3 | N/A | |

**Build order is correct.** Each segment only references objects created in previous segments.

### Note on Segment 1: Pre-Built Venue for Intro Demo

The intro says: *"Quick demo of a completed venue from the participant's perspective."*

This requires a **different, already-published venue** on the demo environment (e.g., Development.1 or OptimAL.EscapeRoom1). The EscapeDirections venue won't exist yet at this point in the session.

**Resolved assumption:** A pre-installed venue (e.g., Development.1 or OptimAL) will be available on the demo environment for the intro walkthrough. Confirm which one during session preparation.

### VS Code Time Budget

| Activity | Minutes | In VS Code? |
|---|---|---|
| Intro demo (existing venue) | 3 | No (in BC browser) |
| Code enums + venue + rooms + tasks + install | 28 | **Yes** |
| Show HTML files | 3 | **Yes** |
| Live demo (F5, play through) | 8 | **Partially** (F5 from VS Code, then BC browser) |
| Wrap-up | 3 | No |

**~31 minutes in VS Code, ~8 minutes in browser, ~6 minutes talking.** Matches your goal of spending most of the session in VS Code.

---

## 6. Correctness of AL Code in Design

Each code block in the design was reviewed line-by-line against the framework source:

### Venue Codeunit — `"EscapeDirections Venue"`
- `GetVenueRec()` — Uses `NavApp.GetCurrentModuleInfo` correctly. Sets all required fields. **Correct.**
- `GetVenue()` — Returns enum value. **Correct.**
- `GetRooms()` — Adds 3 enum values to `List of [Interface iEscapeRoom]`. **Correct** — enum auto-casts.
- `GetRoomCompletedImage()` / `GetVenueCompletedImage()` — Empty implementations. **Correct.**

### Room Codeunits (all 3)
- `GetRoomRec()` — Sets `"Venue Id"`, `Name`, `Description`, `Sequence`. **Correct.**
- `GetRoom()` — Returns enum value. **Correct.**
- `GetRoomDescription()` — `NavApp.GetResourceAsText('...')`. **Correct.**
- `GetTasks()` — Adds enum values. **Correct.**
- `Solve()` — `RichTextBoxPage.Initialize('Solution', NavApp.GetResourceAsText('...'))` then `RunModal()`. **Correct.**

### Task 1: Complete Registration (Polling)
- No `SingleInstance`. **Correct** — polling doesn't need it.
- `IsValid()` reads `CompanyInformation.Get()`, checks `Name = 'Directions 2026'`. **Correct.**
- `var Room: Codeunit "Room1 Find Your Badge ED"` used for `GetTaskRec()`. **Correct** — matches existing pattern.

### Task 2: Make a Connection (Event Subscriber)
- `SingleInstance = true`. **Correct** — required for event subscriber pattern.
- `IsValid()` returns `false`. **Correct.**
- Two event subscribers: `OnAfterInsertEvent` + `OnAfterModifyEvent` on Contact table. **Correct.**
- Room status guard: `Room.GetRoomRec().GetStatus() <> InProgress`. **Correct.**
- Check: `Rec."Company Name" <> 'Directions Partner'`. **Correct** (see Decision #4 for alternatives).
- Calls `this.GetTaskRec().SetStatusCompleted()`. **Correct.**

### Task 3: Prove You Were Here (Test Codeunit)
- `IsValid()` manually manages TestQueue. **Correct** — see Decision #3.
- `Commit()` before `TaskValidationTestRunner.Run(TestQueue)`. **Required** — test runner needs committed data.
- `SelectLatestVersion()` after run. **Required** — test runs in separate transaction.
- `TestQueue.Get(TestCodeunitId)` then `exit(TestQueue.Success)`. **Correct.**

### Test Codeunit: Exit Interview Test
- `Subtype = Test`. **Correct.**
- `TestPermissions = Disabled`. **Correct** — avoids permission issues during validation.
- Single `[Test]` procedure that checks both Room 1 and Room 2 conditions. **Correct.**
- Uses `Error()` for failures (not Assert library). **Correct** — framework's TestRunner catches errors and sets `Success := false`.

### Install Codeunit
- `Subtype = Install`. **Correct.**
- `OnInstallAppPerCompany()` calls `EscapeRoom.UpdateVenue(Enum::...)`. **Correct** — matches all existing venues.

---

## 7. Final Checklist

| Item | Status | Action Needed |
|---|---|---|
| All interface methods implemented | **Pass** | None |
| Enum extensions use `Implementation` keyword | **Pass** | None |
| Validation patterns match framework expectations | **Pass** | None |
| Install codeunit follows established pattern | **Pass** | None |
| HTML files follow constraints (no JS/CSS/emoji) | **Pass** | None |
| HTML Descriptions are mysterious (no HOW) | **Pass** | None |
| ID range 74300-74399 has no conflicts | **Pass** | None |
| Build order in session is dependency-correct | **Pass** | None |
| BC version in app.json | **Fixed** | Updated to `27.0.0.0` in design document |
| Framework dependency version | **Fixed** | Updated to `1.0.0.0` in design document |
| Object IDs via vjeko | **Pass** | Standard workflow — assigned during session prep |
| TestCodeunitId in GetTaskRec | **Pass** | Keep self-contained `IsValid()` (Decision #3) |
| Contact field for validation | **Pass** | Keep `"Company Name"` (Decision #4) |
| Pre-built venue for intro demo segment | **Pass** | Confirm which venue during session prep |

---

## 8. Decisions Summary

| # | Decision | Resolution | Applied |
|---|---|---|---|
| **1** | Framework dependency version | Use `1.0.0.0` | Yes — design document updated |
| ~~2~~ | ~~Pre-assign IDs or use vjeko live~~ | ~~Removed — standard vjeko workflow~~ | N/A |
| **3** | Set `TestCodeunitId` in `GetTaskRec()` or not | Keep current design — `IsValid()` self-contained | No change needed |
| **4** | Contact field: `"Company Name"` vs `Name` | Keep `"Company Name"` (current design) | No change needed |
| **5** | Which venue is pre-installed for intro demo | Confirm during session prep | Prep task |

---

**Overall assessment: The design is sound and ready for implementation.** All AL code is correct against the framework interfaces. The session flow is logically ordered. The three validation patterns are correctly implemented. BC version and framework dependency version have been corrected in the design document. All decisions are resolved.
