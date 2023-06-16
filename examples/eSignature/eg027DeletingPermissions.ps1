# https://developers.docusign.com/docs/esign-rest-api/how-to/permission-profile-deleting/

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
$oAuthAccessToken = Get-Content .\config\ds_access_token.txt

#Set up variables for full code example
# Note: Substitute these values with your own
$APIAccountId = Get-Content .\config\API_ACCOUNT_ID

# Check that we have an profile id
if (Test-Path .\config\PROFILE_ID) {
    $profileID = Get-Content .\config\PROFILE_ID
}
else {
    Write-Output "A profile id is needed. Fix: execute step 24 - Creating Permissions Profiles"
    exit 1
}

# Construct your API headers
#ds-snippet-start:eSign27Step2
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.add("Authorization", "Bearer $oAuthAccessToken")
$headers.add("Accept", "application/json")
$headers.add("Content-Type", "application/json")
#ds-snippet-end:eSign27Step2

# a) Call the eSignature API
# b) Display the JSON response
#ds-snippet-start:eSign27Step3
$uri = "https://demo.docusign.net/restapi/v2.1/accounts/$APIAccountId/permission_profiles/$profileID"

try {
    Invoke-WebRequest -uri $uri -headers $headers -method DELETE
    Write-Output "Profile $profileID has been deleted."
}
catch {
    Write-Output "Unable to delete the permissions profile."
    # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error
    foreach ($header in $_.Exception.Response.Headers) {
        if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
        $int++
    }
    Write-Output "Error : "$_.ErrorDetails.Message
    Write-Output "Command : "$_.InvocationInfo.Line
}
#ds-snippet-end:eSign27Step3