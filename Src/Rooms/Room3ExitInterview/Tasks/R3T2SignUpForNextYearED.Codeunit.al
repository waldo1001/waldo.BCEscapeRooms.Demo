codeunit 74312 "R3T2 Sign Up For Next Year ED" implements iEscapeRoomTask
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
        EscapeRoomTask.Description := 'The organizer asks: see you next year? Register your company as a customer.';
    end;

    procedure GetTask(): Enum "Escape Room Task"
    begin
        exit(Enum::"Escape Room Task"::SignUpForNextYearED);
    end;

    procedure IsValid(): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetRange(Name, 'waldo.be');
        exit(not Customer.IsEmpty());
    end;

    procedure GetHint(): Text
    begin
        exit('Find Customers in Business Central and create a new one.');
    end;
}
