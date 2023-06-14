# https://developers.docusign.com/docs/esign-rest-api/how-to/permission-profile-updating

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
$oAuthAccessToken = Get-Content .\config\ds_access_token.txt

#Set up variables for full code example
# Note: Substitute these values with your own
$APIAccountId = Get-Content .\config\API_ACCOUNT_ID

# Construct your API headers
#ds-snippet-start:eSign26Step2
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.add("Authorization", "Bearer $oAuthAccessToken")
$headers.add("Accept", "application/json")
$headers.add("Content-Type", "application/json")
#ds-snippet-end:eSign26Step2

# Check that we have an profile name
if (Test-Path .\config\PROFILE_NAME) {
    $profileName = Get-Content .\config\PROFILE_NAME
}
else {
    Write-Output "A profile name is needed. Fix: execute step 24 - Creating Permissions Profiles"
    exit 1
}

# Check that we have an profile id
if (Test-Path .\config\PROFILE_ID) {
    $profileID = Get-Content .\config\PROFILE_ID
}
else {
    Write-Output "A profile id is needed. Fix: execute step 24 - Creating Permissions Profiles"
    exit 1
}

# Construct your request body
#ds-snippet-start:eSign26Step3
$body = @"
{
    "permissionProfileName": "${profileName}",
    "settings" : {
        "useNewDocuSignExperienceInterface":0,
        "allowBulkSending":"true",
        "allowEnvelopeSending":"true",
        "allowSignerAttachments":"true",
        "allowTaggingInSendAndCorrect":"true",
        "allowWetSigningOverride":"true",
        "allowedAddressBookAccess":"personalAndShared",
        "allowedTemplateAccess":"share",
        "enableRecipientViewingNotifications":"true",
        "enableSequentialSigningInterface":"true",
        "receiveCompletedSelfSignedDocumentsAsEmailLinks":"false",
        "signingUiVersion":"v2",
        "useNewSendingInterface":"true",
        "allowApiAccess":"true",
        "allowApiAccessToAccount":"true",
        "allowApiSendingOnBehalfOfOthers":"true",
        "allowApiSequentialSigning":"true",
        "enableApiRequestLogging":"true",
        "allowDocuSignDesktopClient":"false",
        "allowSendersToSetRecipientEmailLanguage":"true",
        "allowVaulting":"false",
        "allowedToBeEnvelopeTransferRecipient":"true",
        "enableTransactionPointIntegration":"false",
        "powerFormRole":"admin",
        "vaultingMode":"none"
    }
}
"@
#ds-snippet-end:eSign26Step3

# a) Call the eSignature API
# b) Display the JSON response
#ds-snippet-start:eSign26Step4
$uri = "https://demo.docusign.net/restapi/v2.1/accounts/$APIAccountId/permission_profiles/${profileId}"

try {
    Write-Output "Response:"
    $response = Invoke-WebRequest -uri $uri -headers $headers -body $body -method PUT
    $response.Content | ConvertFrom-Json | ConvertTo-Json
}
catch {
    Write-Output "Updating individual permission settings failed."
    # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error
    foreach ($header in $_.Exception.Response.Headers) {
        if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
        $int++
    }
    Write-Output "Error : "$_.ErrorDetails.Message
    Write-Output "Command : "$_.InvocationInfo.Line
}
#ds-snippet-end:eSign26Step4