codeunit 74510 "Exit Interview Test ED"
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
        if CompanyInformation.Name <> 'iFacto' then
            Error('Your badge still shows the wrong company name. Go back to Company Information and set the Name to "iFacto".');

        // Verify Room 2: A connection was made
        Contact.SetRange("Company Name", 'waldo.be');
        if Contact.IsEmpty() then
            Error('No networking contact found. Create a Contact with Company Name "waldo.be".');
    end;
}
