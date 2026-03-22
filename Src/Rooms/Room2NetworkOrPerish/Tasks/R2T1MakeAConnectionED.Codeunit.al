codeunit 74308 "R2T1 Make A Connection ED" implements iEscapeRoomTask
{
    SingleInstance = true;

    var
        Room: Codeunit "Room2 Network Or Perish ED";

    procedure GetTaskRec() EscapeRoomTask: Record "Escape Room Task"
    var
        Me: ModuleInfo;
    begin
        //To limit the data we need to hardcode some of the values here
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
        ValidateContact(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, OnAfterModifyEvent, '', false, false)]
    local procedure ContactOnAfterModify(var Rec: Record Contact)
    begin
        ValidateContact(Rec);
    end;

    local procedure ValidateContact(var Rec: Record Contact)
    begin
        if Room.GetRoomRec().GetStatus() <> Enum::"Escape Room Status"::InProgress then
            exit;
        if Rec."Company Name" <> 'waldo.be' then exit;

        this.GetTaskRec().SetStatusCompleted();
    end;
}
