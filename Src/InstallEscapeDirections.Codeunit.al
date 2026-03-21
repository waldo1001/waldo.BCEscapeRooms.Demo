codeunit 74311 "Install EscapeDirections"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        EscapeRoom: Codeunit "Escape Room";
    begin
        EscapeRoom.UpdateVenue(Enum::"Escape Room Venue"::EscapeDirections);
    end;
}
