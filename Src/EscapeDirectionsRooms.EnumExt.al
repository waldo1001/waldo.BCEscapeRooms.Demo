enumextension 74501 "EscapeDirections Rooms" extends "Escape Room"
{
    value(74300; FindYourBadgeED)
    {
        Caption = 'Find Your Badge';
        Implementation = iEscapeRoom = "Room1 Find Your Badge ED"; //Suffix, to avoid collisions with other venues
    }
    value(74301; NetworkOrPerishED)
    {
        Caption = 'Network or Perish';
        Implementation = iEscapeRoom = "Room2 Network Or Perish ED";
    }
    value(74302; ExitInterviewED)
    {
        Caption = 'Exit Interview';
        Implementation = iEscapeRoom = "Room3 Exit Interview ED";
    }
}
