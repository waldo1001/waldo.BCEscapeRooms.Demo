codeunit 74307 "R1T1 Complete Registration ED" implements iEscapeRoomTask
{
    var
        Room: Codeunit "Room1 Find Your Badge ED";

    procedure GetTaskRec() EscapeRoomTask: Record "Escape Room Task"
    var
        Me: ModuleInfo;
    begin
        //To limit the data we need to hardcode some of the values here
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
        exit(CompanyInformation.Name = 'iFacto');
    end;

    procedure GetHint(): Text
    begin
        exit('Search for "Company Information" and check the Name field.');
    end;
}
