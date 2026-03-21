codeunit 74306 "Room3 Exit Interview ED" implements iEscapeRoom
{
    procedure GetRoomRec() EscapeRoom: Record "Escape Room"
    var
        Me: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoom."Venue Id" := Me.Name;
        EscapeRoom.Name := Format(this.GetRoom());
        EscapeRoom.Description := 'The organizers verify your conference attendance.';
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
