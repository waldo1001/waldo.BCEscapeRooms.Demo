codeunit 74509 "R3T1 Prove You Were Here ED" implements iEscapeRoomTask
{
    var
        Room: Codeunit "Room3 Exit Interview ED";

    procedure GetTaskRec() EscapeRoomTask: Record "Escape Room Task"
    var
        Me: ModuleInfo;
    begin
        //To limit the data we need to hardcode some of the values here
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

        // Clean up any existing test queue record
        if TestQueue.Get(TestCodeunitId) then
            TestQueue.Delete();

        // Set up the test queue
        TestQueue.Init();
        TestQueue."Codeunit Id" := TestCodeunitId;
        TestQueue.Success := false;
        TestQueue.Insert();

        // Run the test
        Commit();
        TaskValidationTestRunner.Run(TestQueue);

        // Get the result - must reload the record after test run
        SelectLatestVersion();
        TestQueue.Get(TestCodeunitId);

        exit(TestQueue.Success);
    end;

    procedure GetHint(): Text
    begin
        exit('Just click Update Status. The exit interview checks everything automatically.');
    end;
}
