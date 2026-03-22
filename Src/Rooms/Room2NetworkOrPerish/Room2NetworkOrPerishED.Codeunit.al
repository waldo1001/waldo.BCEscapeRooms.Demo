codeunit 74305 "Room2 Network Or Perish ED" implements iEscapeRoom
{
    procedure GetRoomRec() EscapeRoom: Record "Escape Room"
    var
        Me: ModuleInfo;
    begin
        //To limit the data we need to hardcode some of the values here
        NavApp.GetCurrentModuleInfo(Me);
        EscapeRoom."Venue Id" := Me.Name;
        EscapeRoom.Name := Format(this.GetRoom());
        EscapeRoom.Description := 'Network with a fellow partner by creating a new contact.';
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
