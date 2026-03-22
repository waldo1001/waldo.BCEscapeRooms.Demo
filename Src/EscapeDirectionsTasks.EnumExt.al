enumextension 74302 "EscapeDirections Tasks" extends "Escape Room Task"
{
    value(74300; CompleteRegistrationED)
    {
        Caption = 'Complete Registration';
        Implementation = iEscapeRoomTask = "R1T1 Complete Registration ED"; //Also Suffixed
    }
    value(74301; MakeAConnectionED)
    {
        Caption = 'Make a Connection';
        Implementation = iEscapeRoomTask = "R2T1 Make A Connection ED";
    }
    value(74302; ProveYouWereHereED)
    {
        Caption = 'Prove You Were Here';
        Implementation = iEscapeRoomTask = "R3T1 Prove You Were Here ED";
    }
}
