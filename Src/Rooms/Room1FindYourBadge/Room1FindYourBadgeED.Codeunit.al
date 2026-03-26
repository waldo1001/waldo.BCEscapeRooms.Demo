codeunit 74504 "Room1 Find Your Badge ED" implements iEscapeRoom
{
    procedure GetRoomRec() EscapeRoom: Record "Escape Room"
    var
        Me: ModuleInfo;
    begin
        //To limit the data we need to hardcode some of the values here
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoom."Venue Id" := Me.Name;
        EscapeRoom.Name := Format(this.GetRoom());
        EscapeRoom.Description := 'Complete your registration by fixing your company information.';
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
