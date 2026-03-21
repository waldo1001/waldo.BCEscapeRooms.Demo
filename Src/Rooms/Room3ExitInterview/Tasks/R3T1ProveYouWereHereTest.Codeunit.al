codeunit 74310 "Exit Interview Test ED"
{
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure VerifyConferenceAttendance()
    var
        CompanyInformation: Record "Company Information";
        Contact: Record Contact;
    begin
        // Verify Room 1: Badge was completed
        CompanyInformation.Get();
        if CompanyInformation.Name <> 'Directions 2026' then
            Error('Your badge still shows the wrong company name. Go back to Company Information and set the Name to "Directions 2026".');

        // Verify Room 2: A connection was made
        Contact.SetRange("Company Name", 'Directions Partner');
        if Contact.IsEmpty() then
            Error('No networking contact found. Create a Contact with Company Name "Directions Partner".');
    end;
}
