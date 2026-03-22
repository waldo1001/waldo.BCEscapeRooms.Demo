codeunit 74303 "EscapeDirections Venue" implements iEscapeRoomVenue
{
    procedure GetVenueRec() EscapeRoomVenue: Record "Escape Room Venue"
    var
        Me: ModuleInfo;
    begin
        //To limit the data we need to hardcode some of the values here
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
        //Order of the rooms is decided here
        Rooms.Add(Enum::"Escape Room"::FindYourBadgeED);
        Rooms.Add(Enum::"Escape Room"::NetworkOrPerishED);
        Rooms.Add(Enum::"Escape Room"::ExitInterviewED);
    end;

    procedure GetRoomCompletedImage() InStr: InStream
    begin
        NavApp.GetResource('RoomCompleted.png', InStr);
    end;

    procedure GetVenueCompletedImage() InStr: InStream
    begin
        NavApp.GetResource('VenueCompleted.png', InStr);
    end;
}
