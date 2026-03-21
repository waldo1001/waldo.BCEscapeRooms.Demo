# Design Document: Escape Directions Venue

**Purpose:** Complete specification for building the "Escape Directions" venue app — a conference-themed escape room for the Directions partner conference. This document is intended as input for an implementation agent.

**Website reference:** https://www.directionsforpartners.com/

---

## 0. Session Context

### The Presentation

This venue app is being built as the **live demo example** for a **45-minute session** at the Directions partner conference. The session teaches BC developers how to build escape room experiences using the BCTalent.EscapeRoom framework.

**Session title:** Building Escape Room Experiences in Business Central
**Duration:** 45 minutes
**Audience:** BC developers (partners attending Directions)
**Format:** Live coding walkthrough — building this venue from scratch during the session

### Session Outline (Build Order)

The session follows the natural build order of an escape room venue, not a feature tour. Each section builds on the previous one, and participants see a working result at multiple checkpoints.

1. **Intro — What Are Escape Rooms in BC?** (~3 min)
   - Quick demo of a completed venue from the participant's perspective
   - Show the Escape Room page, rooms opening in sequence, tasks completing
   - Set the goal: "We're going to build this from scratch in 40 minutes"

2. **The Three Enums — Your Registration Desk** (~5 min)
   - Create the three enum extensions (Venue, Room, Task)
   - Explain the `Implementation` keyword — how enums map to interface codeunits
   - AL trick aside: `Implementation = iEscapeRoomVenue = "My Venue Codeunit"` on enum values

3. **The Venue Codeunit — Opening the Doors** (~5 min)
   - Implement `iEscapeRoomVenue` (5 methods)
   - Show `GetVenueRec()` with `NavApp.GetCurrentModuleInfo()` pattern
   - Show `GetRooms()` adding enum values (not codeunit instances)
   - AL trick aside: `NavApp.GetCurrentModuleInfo()` for dynamic metadata

4. **Room Codeunits — Designing the Rooms** (~5 min)
   - Implement `iEscapeRoom` for all 3 rooms (5 methods each)
   - Show `Solve()` with `RichTextBoxPage.Initialize()` + `RunModal()`
   - Show `GetRoomDescription()` loading HTML via `NavApp.GetResourceAsText()`
   - AL trick aside: Resource files loaded at runtime

5. **Task Codeunits — The Puzzles** (~10 min, the core)
   - **Room 1 task (Polling):** `IsValid()` returns true/false directly — simplest pattern
   - **Room 2 task (Event Subscriber):** `SingleInstance = true`, room status guard, `SetStatusCompleted()` — the "instant completion" pattern
   - **Room 3 task (Test Codeunit):** `TestQueue` management, `TaskValidationTestRunner`, `SelectLatestVersion()` — the most powerful pattern
   - AL trick aside: `SingleInstance`, `this` keyword on interface methods, `SelectLatestVersion()`

6. **The Install Codeunit — Registration** (~3 min)
   - One-liner: `EscapeRoom.UpdateVenue(Enum::"Escape Room Venue"::EscapeDirections)`
   - Explain the cascade: venue → rooms → tasks, with strategic `Commit()` after each level

7. **HTML Resource Files — Room Descriptions & Solutions** (~3 min)
   - Show the Description/Solution HTML pattern
   - Constraints: no JS, no external CSS, no emoji (BC HTML viewer limitations)
   - Quick tour of one Description + one Solution

8. **Live Demo — Playing Through** (~8 min)
   - Publish the app (F5)
   - Walk through all 3 rooms as a participant
   - Room 1: Change Company Information → click Update Status → task completes (polling)
   - Room 2: Create Contact → task completes instantly (event subscriber)
   - Room 3: Click Update Status → test runs → venue complete (test codeunit)
   - Show the completion cascade in action

9. **Wrap-Up — What You Can Build** (~3 min)
   - Recap the three validation patterns and when to use each
   - Point to the framework repo and documentation
   - Encourage partners to build their own venue apps

### Why This Venue Design Works for the Session

- **3 rooms, 1 task each** — small enough to build live in 45 minutes, large enough to demonstrate all patterns
- **Each room uses a different validation pattern** — polling, event subscriber, test codeunit — so every pattern gets demonstrated exactly once
- **Conference theme ("Escape Directions")** — relatable to the audience, adds personality without complexity
- **Simple participant actions** — change a field, create a contact, click a button — no AL coding required from participants, so the focus stays on the framework
- **Clear cascade demonstration** — Room 1 → Room 2 → Room 3 → venue complete, showing the full lifecycle

---

## 1. Project Setup

### 1.1 app.json

```json
{
  "id": "<generate-new-guid>",
  "name": "EscapeDirections",
  "publisher": "waldo",
  "version": "1.0.0.0",
  "brief": "Escape Directions — a conference-themed escape room venue for the Directions partner conference.",
  "description": "Three rooms that take you through the Directions conference experience: find your badge, network with partners, and pass the exit interview.",
  "privacyStatement": "",
  "EULA": "",
  "help": "",
  "url": "",
  "contextSensitiveHelpUrl": "https://www.directionsforpartners.com/",
  "logo": "",
  "dependencies": [
    {
      "id": "f03c0f0c-d887-4279-b226-dea59737ecf8",
      "name": "BCTalent.EscapeRoom",
      "publisher": "waldo & AJ",
      "version": "1.0.0.0"
    }
  ],
  "screenshots": [],
  "platform": "27.0.0.0",
  "application": "27.0.0.0",
  "idRanges": [
    {
      "from": 74300,
      "to": 74399
    }
  ],
  "resourceExposurePolicy": {
    "allowDebugging": true,
    "allowDownloadingSource": true,
    "includeSourceInSymbolFile": true
  },
  "runtime": "15.0",
  "resourceFolders": [
    "Resources"
  ],
  "target": "Cloud"
}
```

**Notes:**
- ID range 74300-74399 (follows OptimAL at 74200-74299).
- Use `getNextObjectId` (vjeko-al-objid tool) for every AL object before creating it. Never hardcode IDs.
- `resourceFolders` must include `"Resources"` for HTML files to load via `NavApp.GetResourceAsText()`.

### 1.2 Folder Structure

```
EscapeDirections/
├── app.json
├── Venue/
│   ├── EscapeDirectionsVenue.Codeunit.al
│   └── EscapeRoomVenueExt.EnumExt.al
├── Rooms/
│   ├── Room1FindYourBadge.Codeunit.al
│   ├── Room2NetworkOrPerish.Codeunit.al
│   ├── Room3ExitInterview.Codeunit.al
│   └── EscapeRoomExt.EnumExt.al
├── Tasks/
│   ├── R1T1CompleteRegistration.Codeunit.al
│   ├── R2T1MakeAConnection.Codeunit.al
│   ├── R3T1ProveYouWereHere.Codeunit.al
│   ├── R3T1ProveYouWereHereTest.Codeunit.al
│   └── EscapeRoomTaskExt.EnumExt.al
├── Resources/
│   ├── Room1FindYourBadgeDescription.html
│   ├── Room1FindYourBadgeSolution.html
│   ├── Room2NetworkOrPerishDescription.html
│   ├── Room2NetworkOrPerishSolution.html
│   ├── Room3ExitInterviewDescription.html
│   └── Room3ExitInterviewSolution.html
└── Install/
    └── InstallEscapeDirections.Codeunit.al
```

---

## 2. Enum Extensions

Three enum extensions — one per hierarchy level. All in their own `.al` file.

### 2.1 Venue Enum Extension

**File:** `Venue/EscapeRoomVenueExt.EnumExt.al`

```al
enumextension <ID via vjeko> "EscapeDirections Venue" extends "Escape Room Venue"
{
    value(<ID via vjeko>; EscapeDirections)
    {
        Caption = 'Escape Directions';
        Implementation = iEscapeRoomVenue = "EscapeDirections Venue";
    }
}
```

**Key detail:** The `Implementation` keyword maps the enum value directly to the codeunit that implements `iEscapeRoomVenue`. The framework resolves it automatically — no factory pattern needed.

### 2.2 Room Enum Extension

**File:** `Rooms/EscapeRoomExt.EnumExt.al`

```al
enumextension <ID via vjeko> "EscapeDirections Rooms" extends "Escape Room"
{
    value(<ID via vjeko>; FindYourBadgeED)
    {
        Caption = 'Find Your Badge';
        Implementation = iEscapeRoom = "Room1 Find Your Badge ED";
    }
    value(<ID via vjeko>; NetworkOrPerishED)
    {
        Caption = 'Network or Perish';
        Implementation = iEscapeRoom = "Room2 Network Or Perish ED";
    }
    value(<ID via vjeko>; ExitInterviewED)
    {
        Caption = 'Exit Interview';
        Implementation = iEscapeRoom = "Room3 Exit Interview ED";
    }
}
```

**Naming convention:** Suffix `ED` (EscapeDirections) on enum values to avoid collisions with values from other venues. Each existing venue uses its own suffix (e.g., `Dev1`, `Dev2`).

### 2.3 Task Enum Extension

**File:** `Tasks/EscapeRoomTaskExt.EnumExt.al`

```al
enumextension <ID via vjeko> "EscapeDirections Tasks" extends "Escape Room Task"
{
    value(<ID via vjeko>; CompleteRegistrationED)
    {
        Caption = 'Complete Registration';
        Implementation = iEscapeRoomTask = "R1T1 Complete Registration ED";
    }
    value(<ID via vjeko>; MakeAConnectionED)
    {
        Caption = 'Make a Connection';
        Implementation = iEscapeRoomTask = "R2T1 Make A Connection ED";
    }
    value(<ID via vjeko>; ProveYouWereHereED)
    {
        Caption = 'Prove You Were Here';
        Implementation = iEscapeRoomTask = "R3T1 Prove You Were Here ED";
    }
}
```

---

## 3. Venue Codeunit

**File:** `Venue/EscapeDirectionsVenue.Codeunit.al`

Implements `iEscapeRoomVenue`. 5 methods.

```al
codeunit <ID via vjeko> "EscapeDirections Venue" implements iEscapeRoomVenue
{
    procedure GetVenueRec() EscapeRoomVenue: Record "Escape Room Venue"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoomVenue.Id := Me.Name;
        EscapeRoomVenue.Name := Me.Name;
        EscapeRoomVenue.Description := 'Escape the Directions conference — register, network, and prove you were here.';
        EscapeRoomVenue.Venue := Enum::"Escape Room Venue"::EscapeDirections;
        EscapeRoomVenue."App ID" := Me.Id;
        EscapeRoomVenue.Publisher := Me.Publisher;
    end;

    procedure GetVenue(): Enum "Escape Room Venue"
    begin
        exit(Enum::"Escape Room Venue"::EscapeDirections);
    end;

    procedure GetRooms() Rooms: List of [Interface iEscapeRoom]
    begin
        Rooms.Add(Enum::"Escape Room"::FindYourBadgeED);
        Rooms.Add(Enum::"Escape Room"::NetworkOrPerishED);
        Rooms.Add(Enum::"Escape Room"::ExitInterviewED);
    end;

    procedure GetRoomCompletedImage() InStr: InStream
    begin
        // No image — intentionally empty
    end;

    procedure GetVenueCompletedImage() InStr: InStream
    begin
        // No image — intentionally empty
    end;
}
```

**Critical patterns:**
- `GetRooms()` adds **enum values**, not codeunit instances. The enum's `Implementation` keyword resolves to the codeunit.
- `GetVenueRec()` uses `NavApp.GetCurrentModuleInfo(Me)` to populate `Id`, `Name`, `App ID`, `Publisher` dynamically.
- Image procedures return nothing — this venue has no images. The framework handles empty InStreams gracefully.

---

## 4. Room Codeunits

Each implements `iEscapeRoom`. 5 methods: `GetRoomRec()`, `GetRoom()`, `GetRoomDescription()`, `GetTasks()`, `Solve()`.

### 4.1 Room 1: Find Your Badge

**File:** `Rooms/Room1FindYourBadge.Codeunit.al`

**Theme:** You arrived at the Directions conference but the registration desk says your badge is incomplete. Your company information is missing — fix it before you can get your badge.

```al
codeunit <ID via vjeko> "Room1 Find Your Badge ED" implements iEscapeRoom
{
    procedure GetRoomRec() EscapeRoom: Record "Escape Room"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoom."Venue Id" := Me.Name;
        EscapeRoom.Name := Format(this.GetRoom());
        EscapeRoom.Description := 'Complete your registration by fixing your company information.';
        EscapeRoom.Sequence := 1;
    end;

    procedure GetRoom(): Enum "Escape Room"
    begin
        exit(Enum::"Escape Room"::FindYourBadgeED);
    end;

    procedure GetRoomDescription() RoomDescription: Text
    begin
        RoomDescription := NavApp.GetResourceAsText('Room1FindYourBadgeDescription.html');
    end;

    procedure GetTasks() Tasks: List of [Interface iEscapeRoomTask]
    begin
        Tasks.Add(Enum::"Escape Room Task"::CompleteRegistrationED);
    end;

    procedure Solve()
    var
        RichTextBoxPage: Page "Rich Text Box Page";
    begin
        RichTextBoxPage.Initialize('Solution', NavApp.GetResourceAsText('Room1FindYourBadgeSolution.html'));
        RichTextBoxPage.RunModal();
    end;
}
```

### 4.2 Room 2: Network or Perish

**File:** `Rooms/Room2NetworkOrPerish.Codeunit.al`

**Theme:** The whole point of Directions is networking. You can't move on until you've made a connection — create a contact named "Directions Partner".

```al
codeunit <ID via vjeko> "Room2 Network Or Perish ED" implements iEscapeRoom
{
    procedure GetRoomRec() EscapeRoom: Record "Escape Room"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoom."Venue Id" := Me.Name;
        EscapeRoom.Name := Format(this.GetRoom());
        EscapeRoom.Description := 'Network with a fellow partner by creating a new contact.';
        EscapeRoom.Sequence := 2;
    end;

    procedure GetRoom(): Enum "Escape Room"
    begin
        exit(Enum::"Escape Room"::NetworkOrPerishED);
    end;

    procedure GetRoomDescription() RoomDescription: Text
    begin
        RoomDescription := NavApp.GetResourceAsText('Room2NetworkOrPerishDescription.html');
    end;

    procedure GetTasks() Tasks: List of [Interface iEscapeRoomTask]
    begin
        Tasks.Add(Enum::"Escape Room Task"::MakeAConnectionED);
    end;

    procedure Solve()
    var
        RichTextBoxPage: Page "Rich Text Box Page";
    begin
        RichTextBoxPage.Initialize('Solution', NavApp.GetResourceAsText('Room2NetworkOrPerishSolution.html'));
        RichTextBoxPage.RunModal();
    end;
}
```

### 4.3 Room 3: Exit Interview

**File:** `Rooms/Room3ExitInterview.Codeunit.al`

**Theme:** The conference organizers are at the exit and want proof you actually participated. A comprehensive check validates everything you did.

```al
codeunit <ID via vjeko> "Room3 Exit Interview ED" implements iEscapeRoom
{
    procedure GetRoomRec() EscapeRoom: Record "Escape Room"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoom."Venue Id" := Me.Name;
        EscapeRoom.Name := Format(this.GetRoom());
        EscapeRoom.Description := 'The organizers verify your conference attendance.';
        EscapeRoom.Sequence := 3;
    end;

    procedure GetRoom(): Enum "Escape Room"
    begin
        exit(Enum::"Escape Room"::ExitInterviewED);
    end;

    procedure GetRoomDescription() RoomDescription: Text
    begin
        RoomDescription := NavApp.GetResourceAsText('Room3ExitInterviewDescription.html');
    end;

    procedure GetTasks() Tasks: List of [Interface iEscapeRoomTask]
    begin
        Tasks.Add(Enum::"Escape Room Task"::ProveYouWereHereED);
    end;

    procedure Solve()
    var
        RichTextBoxPage: Page "Rich Text Box Page";
    begin
        RichTextBoxPage.Initialize('Solution', NavApp.GetResourceAsText('Room3ExitInterviewSolution.html'));
        RichTextBoxPage.RunModal();
    end;
}
```

---

## 5. Task Codeunits

Each task demonstrates one of the three validation patterns.

### 5.1 Task 1: Complete Registration (Pattern: Polling)

**File:** `Tasks/R1T1CompleteRegistration.Codeunit.al`

**Validation pattern:** Polling. `IsValid()` returns `true` when the condition is met. The framework calls it when the user clicks "Update Status".

**What the participant does:** Open Company Information, set the Name field to "Directions 2026".

**Why this pattern:** The Company Information record already exists — it's a Modify, not an Insert. Polling is the natural fit because we're checking a field value on an existing record. No event subscriber is needed.

```al
codeunit <ID via vjeko> "R1T1 Complete Registration ED" implements iEscapeRoomTask
{
    var
        Room: Codeunit "Room1 Find Your Badge ED";

    procedure GetTaskRec() EscapeRoomTask: Record "Escape Room Task"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoomTask."Venue Id" := Me.Name;
        EscapeRoomTask."Room Name" := Format(Room.GetRoom());
        EscapeRoomTask.Name := Format(this.GetTask());
        EscapeRoomTask.Description := 'Fix your company name on the conference badge.';
    end;

    procedure GetTask(): Enum "Escape Room Task"
    begin
        exit(Enum::"Escape Room Task"::CompleteRegistrationED);
    end;

    procedure IsValid(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit(false);
        exit(CompanyInformation.Name = 'Directions 2026');
    end;

    procedure GetHint(): Text
    begin
        exit('Search for "Company Information" and check the Name field.');
    end;
}
```

**Key details:**
- No `SingleInstance` property needed — polling is stateless.
- `var Room: Codeunit ...` is declared to get the Room Name via `Format(Room.GetRoom())`.
- `IsValid()` does a simple record read + field comparison. Returns `true`/`false`.
- The framework calls `IsValid()` when the user clicks "Update Status" on the room page. If it returns `true`, the task is marked completed.

### 5.2 Task 2: Make a Connection (Pattern: Event Subscriber)

**File:** `Tasks/R2T1MakeAConnection.Codeunit.al`

**Validation pattern:** Event Subscriber. `IsValid()` always returns `false`. An `OnAfterInsertEvent` subscriber on the Contact table detects when the participant creates the right contact and calls `SetStatusCompleted()`.

**What the participant does:** Create a new Contact with Company Name "Directions Partner".

**Why this pattern:** We're detecting a *new record creation* — the moment it happens, the task auto-completes. This is the signature use case for event subscribers.

```al
codeunit <ID via vjeko> "R2T1 Make A Connection ED" implements iEscapeRoomTask
{
    SingleInstance = true;

    var
        Room: Codeunit "Room2 Network Or Perish ED";

    procedure GetTaskRec() EscapeRoomTask: Record "Escape Room Task"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoomTask."Venue Id" := Me.Name;
        EscapeRoomTask."Room Name" := Format(Room.GetRoom());
        EscapeRoomTask.Name := Format(this.GetTask());
        EscapeRoomTask.Description := 'Create a new contact to expand your network.';
    end;

    procedure GetTask(): Enum "Escape Room Task"
    begin
        exit(Enum::"Escape Room Task"::MakeAConnectionED);
    end;

    procedure IsValid(): Boolean
    begin
        exit(false);
    end;

    procedure GetHint(): Text
    begin
        exit('Search for "Contacts" and create a new contact. The company name matters.');
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnAfterInsertEvent, '', false, false)]
    local procedure ContactOnAfterInsert(var Rec: Record Contact)
    begin
        if Room.GetRoomRec().GetStatus() <> Enum::"Escape Room Status"::InProgress then
            exit;

        if Rec."Company Name" <> 'Directions Partner' then
            exit;

        this.GetTaskRec().SetStatusCompleted();
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnAfterModifyEvent, '', false, false)]
    local procedure ContactOnAfterModify(var Rec: Record Contact)
    begin
        if Room.GetRoomRec().GetStatus() <> Enum::"Escape Room Status"::InProgress then
            exit;

        if Rec."Company Name" <> 'Directions Partner' then
            exit;

        this.GetTaskRec().SetStatusCompleted();
    end;
}
```

**Critical details:**
- **`SingleInstance = true`** is REQUIRED. Without it, every event fires on a fresh codeunit instance and the `Room` variable won't have the state needed for the guard check. The framework documentation is explicit about this.
- **Room status guard:** `if Room.GetRoomRec().GetStatus() <> InProgress then exit;` — this prevents the subscriber from firing on every Contact insert in BC, even outside this escape room. Only act when Room 2 is actually in progress.
- **Both OnAfterInsertEvent AND OnAfterModifyEvent:** The participant might create the contact first and then set the company name (triggering a Modify, not an Insert). Subscribing to both covers both workflows. This is the same pattern used in `CreateCustomer Dev1`.
- **`SetStatusCompleted()` cascade:** This single call marks the task as completed, fires a notification, logs telemetry, then checks if the room should close (FlowField `No. of Uncompleted Tasks` = 0), and if so, opens the next room.

### 5.3 Task 3: Prove You Were Here (Pattern: Test Codeunit)

**File:** `Tasks/R3T1ProveYouWereHere.Codeunit.al`

**Validation pattern:** Test Codeunit. `IsValid()` runs a test codeunit via the framework's `Task Validation Test Runner`. The test codeunit performs multi-step validation.

**What the participant does:** Nothing extra — this task validates that the results from Rooms 1 and 2 are still in place. The participant just clicks "Update Status" and the test runs automatically.

**Why this pattern:** It demonstrates that test codeunits can perform complex, multi-step validation that combines assertions across multiple tables. It's the natural "final gate" for an escape room.

```al
codeunit <ID via vjeko> "R3T1 Prove You Were Here ED" implements iEscapeRoomTask
{
    var
        Room: Codeunit "Room3 Exit Interview ED";

    procedure GetTaskRec() EscapeRoomTask: Record "Escape Room Task"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoomTask."Venue Id" := Me.Name;
        EscapeRoomTask."Room Name" := Format(Room.GetRoom());
        EscapeRoomTask.Name := Format(this.GetTask());
        EscapeRoomTask.Description := 'The organizers verify all your conference activities.';
    end;

    procedure GetTask(): Enum "Escape Room Task"
    begin
        exit(Enum::"Escape Room Task"::ProveYouWereHereED);
    end;

    procedure IsValid(): Boolean
    var
        TestQueue: Record "Test Queue";
        TaskValidationTestRunner: Codeunit "Task Validation Test Runner";
        TestCodeunitId: Integer;
    begin
        TestCodeunitId := Codeunit::"Exit Interview Test ED";

        if TestQueue.Get(TestCodeunitId) then
            TestQueue.Delete();

        TestQueue.Init();
        TestQueue."Codeunit Id" := TestCodeunitId;
        TestQueue.Success := false;
        TestQueue.Insert();

        Commit();
        TaskValidationTestRunner.Run(TestQueue);

        SelectLatestVersion();
        TestQueue.Get(TestCodeunitId);

        exit(TestQueue.Success);
    end;

    procedure GetHint(): Text
    begin
        exit('Just click Update Status. The exit interview checks everything automatically.');
    end;
}
```

**The Test Codeunit:**

**File:** `Tasks/R3T1ProveYouWereHereTest.Codeunit.al`

```al
codeunit <ID via vjeko> "Exit Interview Test ED"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure VerifyConferenceAttendance()
    var
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
    begin
        // Verify Room 1: Badge was completed
        CompanyInformation.Get();
        if CompanyInformation.Name <> 'Directions 2026' then
            Error('Your badge still shows the wrong company name. Go back to Company Information and set the Name to "Directions 2026".');

        // Verify Room 2: A connection was made
        Contact.SetRange("Company Name", 'Directions Partner');
        if Contact.IsEmpty() then
            Error('No networking contact found. Create a Contact with Company Name "Directions Partner".');
    end;
}
```

**Critical details about the Test Codeunit pattern:**
- The task codeunit's `IsValid()` does NOT simply return `true`/`false`. It orchestrates the test run:
  1. Clean up any existing TestQueue record for this test codeunit ID
  2. Insert a fresh TestQueue record with `Success = false`
  3. `Commit()` — required before running the test
  4. Run the test via `TaskValidationTestRunner.Run(TestQueue)`
  5. `SelectLatestVersion()` — required to read the updated TestQueue after the test modifies it in its own transaction
  6. Read the TestQueue result and return `TestQueue.Success`
- The test codeunit uses `Error()` for failures (not Assert functions from a test library). The framework's `Task Validation Test Runner` catches errors and sets `TestQueue.Success := false`.
- `TestPermissions = Disabled` is set so the test can read tables without permission set constraints.
- No `SingleInstance` needed on the task codeunit — there are no event subscribers.

---

## 6. Install Codeunit

**File:** `Install/InstallEscapeDirections.Codeunit.al`

```al
codeunit <ID via vjeko> "Install EscapeDirections"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        EscapeRoom: Codeunit "Escape Room";
    begin
        EscapeRoom.UpdateVenue(Enum::"Escape Room Venue"::EscapeDirections);
    end;
}
```

**What `UpdateVenue()` does behind the scenes:**
1. Calls `GetVenueRec()` on the venue codeunit → inserts the venue record if it doesn't exist. `Commit()`.
2. Iterates `GetRooms()` → for each room, calls `GetRoomRec()`, sets `Room` enum and `Sequence`, inserts. `Commit()` after each.
3. For each room, iterates `GetTasks()` → for each task, calls `GetTaskRec()`, sets `Task` enum and `Sequence`, inserts. If `TestCodeunitId <> 0`, registers it in the `Test Queue` table. `Commit()` after each.
4. **Existing records are skipped** (idempotent via `Find('=')`).
5. **Strategic commits:** The framework commits after each level. If task 2 fails, the venue, rooms, and task 1 are already saved.

---

## 7. HTML Resource Files

All 6 HTML files go in the `Resources/` folder. They are loaded at runtime via `NavApp.GetResourceAsText('filename.html')`.

**Constraints:**
- No JavaScript (BC HTML viewer doesn't execute it)
- No external CSS (inline styles only)
- No emoji, emoticons, or special Unicode characters (BC HTML viewer can't render them)
- No images in these files (we have no image resources in this venue)
- No `<link>` or `<script>` tags

### 7.1 Room1FindYourBadgeDescription.html

**Purpose:** Presents the challenge for Room 1. Tells participants WHAT is wrong, not HOW to fix it. Must be mysterious.

```html
<!DOCTYPE html>
<html>

<head>
    <title>Room 1: Find Your Badge</title>
</head>

<body>
    <h1>Room 1: Find Your Badge</h1>

    <h2>TL;DR</h2>
    <p>Your conference badge has the wrong company name on it. Fix it in Business Central so the
        registration desk can reprint it. The system checks automatically when you click
        <strong>Update Status</strong>.</p>

    <h2>The Challenge</h2>
    <p>You just arrived at the Directions conference, but the badge they printed shows your old
        company name. The registration desk won't let you in until your badge matches the
        conference records. Every minute you spend here is a session you're missing.</p>

    <h2>Your Mission</h2>

    <h3>Fix Your Badge</h3>
    <p>Somewhere in Business Central, there is a page where your company details are stored.
        The conference records expect the company name to read <strong>Directions 2026</strong>.</p>
    <ol>
        <li>Find the page in Business Central where company details are maintained</li>
        <li>Update the company name to match what the conference expects</li>
    </ol>
    <p><strong>Hint:</strong> Search for something related to your company's own information.</p>
    <p><em>Click <strong>Update Status</strong> on the room page after making the change.
        The system will verify the name is correct.</em></p>

    <p><em><strong>Update Status:</strong> Not all steps are captured automatically. Hit the
        <strong>Update Status</strong> button on the room page to check if you have completed
        steps that weren't registered yet.</em></p>

    <h2>What's Next</h2>
    <p><strong>Room 2:</strong> Now that you have your badge, it's time to network.</p>
</body>

</html>
```

### 7.2 Room1FindYourBadgeSolution.html

```html
<!DOCTYPE html>
<html>

<head>
    <title>Solution: Room 1 - Find Your Badge</title>
</head>

<body>
    <h1>Solution: Room 1 - Find Your Badge</h1>

    <p>The company name is stored on the Company Information page. You need to change it to match
        the conference records.</p>

    <h2>Fix Your Badge</h2>

    <h3>Step 1: Open Company Information</h3>
    <ol>
        <li>In Business Central, use the search bar (magnifying glass or Alt+Q)</li>
        <li>Search for <strong>Company Information</strong></li>
        <li>Open the <strong>Company Information</strong> page</li>
    </ol>

    <h3>Step 2: Update the Company Name</h3>
    <ol>
        <li>Find the <strong>Name</strong> field at the top of the page</li>
        <li>Change it to <strong>Directions 2026</strong> (exact spelling matters)</li>
        <li>Close the page (the change saves automatically)</li>
    </ol>

    <h4>Why This Matters:</h4>
    <ul>
        <li>The task uses <strong>polling validation</strong> — the framework calls <code>IsValid()</code>
            when you click Update Status</li>
        <li><code>IsValid()</code> reads the Company Information record and checks the Name field</li>
        <li>No event subscriber is needed because we're checking an existing record's field value</li>
    </ul>

    <h2>Verification</h2>
    <ul>
        <li>Company Information page shows Name = <strong>Directions 2026</strong></li>
        <li>Task status shows <strong>Completed</strong> after clicking Update Status</li>
        <li>Room 1 closes and Room 2 opens automatically</li>
    </ul>
    <p><strong>Important:</strong> Don't forget to click the <strong>Update Status</strong> button.</p>

    <h2>What You've Accomplished</h2>
    <ul>
        <li>Found and modified company-level data in Business Central</li>
        <li>Experienced the <strong>polling</strong> validation pattern — the simplest form of task validation</li>
    </ul>
</body>

</html>
```

### 7.3 Room2NetworkOrPerishDescription.html

```html
<!DOCTYPE html>
<html>

<head>
    <title>Room 2: Network or Perish</title>
</head>

<body>
    <h1>Room 2: Network or Perish</h1>

    <h2>TL;DR</h2>
    <p>Create a new contact to represent a partner you met at the conference. The system detects
        the moment you create the right contact and completes the task automatically.</p>

    <h2>The Challenge</h2>
    <p>The Directions conference is all about making connections with fellow partners. You've got
        your badge, you're in the venue, but the organizers track networking activity. You need to
        log at least one new connection before you can leave. First impressions count — make sure
        the contact represents a <strong>Directions Partner</strong>.</p>

    <h2>Your Mission</h2>

    <h3>Make a Connection</h3>
    <p>Find where Business Central stores contact information and create a new contact that
        represents a partner you met at the conference. The company name on the contact is what
        the organizers check.</p>
    <ol>
        <li>Navigate to the contact list in Business Central</li>
        <li>Create a new contact record</li>
        <li>Set the company name to <strong>Directions Partner</strong></li>
    </ol>
    <p><strong>Hint:</strong> Search for contacts. The company name field is what matters, not the
        contact's personal name.</p>
    <p><em>This task completes automatically the moment you create the right contact. No need to
        click Update Status — but you can if you want to double-check.</em></p>

    <p><em><strong>Update Status:</strong> Not all steps are captured automatically. Hit the
        <strong>Update Status</strong> button on the room page to check if you have completed
        steps that weren't registered yet.</em></p>

    <h2>What's Next</h2>
    <p><strong>Room 3:</strong> Time to leave — but first, the organizers want to verify your attendance.</p>
</body>

</html>
```

### 7.4 Room2NetworkOrPerishSolution.html

```html
<!DOCTYPE html>
<html>

<head>
    <title>Solution: Room 2 - Network or Perish</title>
</head>

<body>
    <h1>Solution: Room 2 - Network or Perish</h1>

    <p>You need to create a Contact record with Company Name set to "Directions Partner".</p>

    <h2>Make a Connection</h2>

    <h3>Step 1: Open the Contact List</h3>
    <ol>
        <li>In Business Central, search for <strong>Contacts</strong></li>
        <li>Open the <strong>Contacts</strong> list page</li>
    </ol>

    <h3>Step 2: Create a New Contact</h3>
    <ol>
        <li>Click <strong>New</strong> to create a new contact</li>
        <li>Set the <strong>Company Name</strong> field to <strong>Directions Partner</strong>
            (exact spelling matters)</li>
        <li>Fill in any other required fields as needed</li>
        <li>Close the contact card</li>
    </ol>

    <h4>Why This Matters:</h4>
    <ul>
        <li>This task uses the <strong>event subscriber</strong> validation pattern</li>
        <li>The task codeunit subscribes to <code>OnAfterInsertEvent</code> and
            <code>OnAfterModifyEvent</code> on the Contact table</li>
        <li>The moment a Contact with Company Name "Directions Partner" is inserted or modified,
            the subscriber calls <code>SetStatusCompleted()</code></li>
        <li>The <strong>room status guard</strong> (<code>GetStatus() &lt;&gt; InProgress</code>)
            prevents the subscriber from firing outside this room</li>
        <li><strong>SingleInstance = true</strong> on the codeunit ensures the subscriber shares
            state with the task instance</li>
    </ul>

    <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
        <p><strong>Why both Insert and Modify?</strong> The participant might create the contact
            first (Insert) and then set the company name afterward (Modify). Subscribing to both
            events ensures the task completes regardless of the order.</p>
    </div>

    <h2>Verification</h2>
    <ul>
        <li>A Contact with Company Name <strong>Directions Partner</strong> exists</li>
        <li>Task completed <strong>automatically</strong> (no Update Status click needed)</li>
        <li>Room 2 closes and Room 3 opens automatically</li>
    </ul>

    <h2>What You've Accomplished</h2>
    <ul>
        <li>Created contact data in Business Central</li>
        <li>Experienced the <strong>event subscriber</strong> validation pattern — the task completed
            instantly without clicking Update Status</li>
        <li>Understood why <strong>SingleInstance</strong> and <strong>room status guards</strong>
            are essential for event-based validation</li>
    </ul>
</body>

</html>
```

### 7.5 Room3ExitInterviewDescription.html

```html
<!DOCTYPE html>
<html>

<head>
    <title>Room 3: Exit Interview</title>
</head>

<body>
    <h1>Room 3: Exit Interview</h1>

    <h2>TL;DR</h2>
    <p>The conference organizers run a final verification before you can leave. Click
        <strong>Update Status</strong> and the system will check everything automatically.</p>

    <h2>The Challenge</h2>
    <p>You've registered and you've networked. Now the conference organizers at the exit want
        proof that you really participated. They run an automated check that verifies everything
        you did in the previous rooms. If anything is missing, they'll tell you what to fix.</p>

    <h2>Your Mission</h2>

    <h3>Pass the Exit Check</h3>
    <p>There is nothing new to do here. The exit interview runs an automated verification
        that checks your work from Room 1 and Room 2. If everything is in order, you're free
        to go.</p>
    <ol>
        <li>Click <strong>Update Status</strong> on the room page</li>
        <li>The system runs a comprehensive check</li>
        <li>If something is missing, the error message tells you exactly what</li>
    </ol>
    <p><strong>Hint:</strong> If it fails, read the error message carefully — it tells you
        exactly what the organizers found missing.</p>
    <p><em>This task uses an automated test to validate your results. Click
        <strong>Update Status</strong> to trigger it.</em></p>

    <p><em><strong>Update Status:</strong> Not all steps are captured automatically. Hit the
        <strong>Update Status</strong> button on the room page to check if you have completed
        steps that weren't registered yet.</em></p>
</body>

</html>
```

**Note:** Room 3 is the final room — no "What's Next" section.

### 7.6 Room3ExitInterviewSolution.html

```html
<!DOCTYPE html>
<html>

<head>
    <title>Solution: Room 3 - Exit Interview</title>
</head>

<body>
    <h1>Solution: Room 3 - Exit Interview</h1>

    <p>The exit interview is an automated test that verifies the results of Room 1 and Room 2.
        There is nothing new to configure — just ensure the previous rooms were completed correctly.</p>

    <h2>Pass the Exit Check</h2>

    <h3>What the Test Checks</h3>
    <p>The automated verification runs two assertions:</p>
    <ol>
        <li><strong>Company Information</strong> — Name must be <strong>Directions 2026</strong>
            (from Room 1)</li>
        <li><strong>Contact</strong> — A Contact with Company Name <strong>Directions Partner</strong>
            must exist (from Room 2)</li>
    </ol>

    <h3>If the Test Fails</h3>
    <p>The error message tells you exactly what is missing. Go back and fix it:</p>
    <ul>
        <li>If the company name is wrong: open <strong>Company Information</strong> and correct it</li>
        <li>If the contact is missing: open <strong>Contacts</strong> and create one with
            Company Name <strong>Directions Partner</strong></li>
    </ul>

    <h4>Why This Matters:</h4>
    <ul>
        <li>This task uses the <strong>test codeunit</strong> validation pattern</li>
        <li>A codeunit with <code>Subtype = Test</code> runs when Update Status is clicked</li>
        <li>The test performs multi-step validation across multiple tables — something that
            simple polling or event subscribers cannot do as cleanly</li>
        <li>The framework's <strong>Task Validation Test Runner</strong> handles execution:
            it catches errors and translates them into pass/fail results</li>
        <li><code>SelectLatestVersion()</code> ensures the task reads the test result from the
            database, not from NST cache</li>
    </ul>

    <div style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;">
        <p><strong>The test codeunit pattern is the most powerful validation option.</strong>
            It can test anything a normal AL test can test — table data, page availability,
            complex business logic, even UI interactions via page test actions.</p>
    </div>

    <h2>Verification</h2>
    <ul>
        <li>Click <strong>Update Status</strong> — the test runs automatically</li>
        <li>Task shows <strong>Completed</strong></li>
        <li>Room 3 closes, and the venue is completed</li>
        <li>The venue's Stop DateTime is set and telemetry is logged</li>
    </ul>

    <h2>What You've Accomplished</h2>
    <ul>
        <li>Experienced all <strong>three validation patterns</strong> in one venue:
            <strong>polling</strong> (Room 1), <strong>event subscriber</strong> (Room 2),
            and <strong>test codeunit</strong> (Room 3)</li>
        <li>Saw the <strong>completion cascade</strong> in action — task complete triggers
            room close triggers next room open (or venue close)</li>
        <li>Escaped the Directions conference</li>
    </ul>
</body>

</html>
```

---

## 8. Object Summary

| # | Object Type | ID | Name | File |
|---|---|---|---|---|
| 1 | EnumExtension | vjeko | `"EscapeDirections Venue"` extends `"Escape Room Venue"` | `Venue/EscapeRoomVenueExt.EnumExt.al` |
| 2 | EnumExtension | vjeko | `"EscapeDirections Rooms"` extends `"Escape Room"` | `Rooms/EscapeRoomExt.EnumExt.al` |
| 3 | EnumExtension | vjeko | `"EscapeDirections Tasks"` extends `"Escape Room Task"` | `Tasks/EscapeRoomTaskExt.EnumExt.al` |
| 4 | Codeunit | vjeko | `"EscapeDirections Venue"` implements `iEscapeRoomVenue` | `Venue/EscapeDirectionsVenue.Codeunit.al` |
| 5 | Codeunit | vjeko | `"Room1 Find Your Badge ED"` implements `iEscapeRoom` | `Rooms/Room1FindYourBadge.Codeunit.al` |
| 6 | Codeunit | vjeko | `"Room2 Network Or Perish ED"` implements `iEscapeRoom` | `Rooms/Room2NetworkOrPerish.Codeunit.al` |
| 7 | Codeunit | vjeko | `"Room3 Exit Interview ED"` implements `iEscapeRoom` | `Rooms/Room3ExitInterview.Codeunit.al` |
| 8 | Codeunit | vjeko | `"R1T1 Complete Registration ED"` implements `iEscapeRoomTask` | `Tasks/R1T1CompleteRegistration.Codeunit.al` |
| 9 | Codeunit | vjeko | `"R2T1 Make A Connection ED"` implements `iEscapeRoomTask` | `Tasks/R2T1MakeAConnection.Codeunit.al` |
| 10 | Codeunit | vjeko | `"R3T1 Prove You Were Here ED"` implements `iEscapeRoomTask` | `Tasks/R3T1ProveYouWereHere.Codeunit.al` |
| 11 | Codeunit (Test) | vjeko | `"Exit Interview Test ED"` (Subtype = Test) | `Tasks/R3T1ProveYouWereHereTest.Codeunit.al` |
| 12 | Codeunit (Install) | vjeko | `"Install EscapeDirections"` (Subtype = Install) | `Install/InstallEscapeDirections.Codeunit.al` |

**Total: 12 AL objects + 6 HTML resource files.**

---

## 9. Validation Pattern Reference

| Room | Task | Pattern | `IsValid()` returns | How it completes | `SingleInstance` |
|---|---|---|---|---|---|
| Room 1 | Complete Registration | Polling | `true` when condition met | User clicks Update Status | No |
| Room 2 | Make a Connection | Event Subscriber | Always `false` | `SetStatusCompleted()` called by subscriber | **Yes** |
| Room 3 | Prove You Were Here | Test Codeunit | Runs test, returns `TestQueue.Success` | User clicks Update Status, test runs | No |

---

## 10. Implementation Order

Build in this order to avoid compile errors (forward references):

1. `app.json`
2. **Enum extensions** (all 3) — these are referenced by everything else
3. **Room codeunits** (all 3) — referenced as `var` in task codeunits
4. **Venue codeunit** — references room enums in `GetRooms()`
5. **Task codeunits** (all 3 + test codeunit) — reference room codeunits as `var`
6. **Install codeunit** — references venue enum
7. **HTML resource files** (all 6) — referenced by room codeunits at runtime

**Important:** Use `getNextObjectId` from the vjeko-al-objid tool for every object ID before creating it. The enum extension IDs and enum *value* IDs must also be allocated. The ID range in app.json is 74300-74399.

---

## 11. Framework Version Dependency

This design targets:
- **BCTalent.EscapeRoom** version `1.3.0.0` (latest)
- **BC runtime** `15.0`
- **BC application** `26.0.0.0`

Framework objects referenced:
- `Enum "Escape Room Venue"` (73920)
- `Enum "Escape Room"` (73922)
- `Enum "Escape Room Task"` (73923)
- `Enum "Escape Room Status"` (73921)
- `Record "Escape Room Venue"` (73926)
- `Record "Escape Room"` (73920)
- `Record "Escape Room Task"` (73922)
- `Record "Test Queue"` (framework table)
- `Codeunit "Escape Room"` (73922) — `UpdateVenue()`
- `Codeunit "Task Validation Test Runner"` (framework codeunit)
- `Page "Rich Text Box Page"` (73929)
- Interface `iEscapeRoomVenue`, `iEscapeRoom`, `iEscapeRoomTask`
