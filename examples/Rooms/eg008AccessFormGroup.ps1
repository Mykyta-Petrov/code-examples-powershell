# Get required environment variables from .\config\settings.json file
$accessToken = Get-Content .\config\ds_access_token.txt
$APIAccountId = Get-Content .\config\API_ACCOUNT_ID

# Construct your API headers
#ds-snippet-start:Rooms9Step2
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.add("Authorization", "Bearer $accessToken")
$headers.add("Accept", "application/json")
$headers.add("Content-Type", "application/json")
#ds-snippet-end:Rooms9Step2


# Get an office ID
#ds-snippet-start:Rooms9Step3
$base_path = "https://demo.rooms.docusign.com"
$uri = "$base_path/restapi/v2/accounts/$APIAccountId/offices"

try {
  Write-Output "Response:"
  $response = Invoke-WebRequest -uri $uri -headers $headers -method GET
  $response.Content
  # Retrieve the form group ID
  $obj = $response.Content | ConvertFrom-Json
  $officeID = $obj.officeSummaries[0].officeId
}
catch {
  Write-Output "Unable to retrieve an office ID"
  # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error

  foreach ($header in $_.Exception.Response.Headers) {
    if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
    $int++
  }
  Write-Output "Error : "$_.ErrorDetails.Message
  Write-Output "Command : "$_.InvocationInfo.Line
}
#ds-snippet-end:Rooms9Step3

# Get form group ID from the .\config\FORM_GROUP_ID file
if (Test-Path .\config\FORM_GROUP_ID) {
#ds-snippet-start:Rooms9Step4
  $formGroupID = Get-Content .\config\FORM_GROUP_ID
#ds-snippet-end:Rooms9Step4
}
else {
  Write-Output "A form group ID is needed. Fix: execute code example 7 - Create a form group..."
  exit 1
}


# Call the Rooms API
#ds-snippet-start:Rooms9Step5
$uri = "$base_path/restapi/v2/accounts/$APIAccountId/form_groups/$formGroupID/grant_office_access/$officeID"

try {
  Write-Output "Response:"
  $response = Invoke-WebRequest -uri $uri -headers $headers -method POST -body $body
  $response.StatusCode

  # check that we have got a 204 Status code response
  if ($response.StatusCode -ne "204" ) {
    Write-Output "Unable to assign the provided form group ID to the provided office ID!"
    exit 1
  }
}
catch {
  Write-Output "Unable to grant office access to a form group"
  # On failure, display a notification, X-DocuSign-TraceToken, error message, and the command that triggered the error

  foreach ($header in $_.Exception.Response.Headers) {
    if ($header -eq "X-DocuSign-TraceToken") { Write-Output "TraceToken : " $_.Exception.Response.Headers[$int] }
    $int++
  }
  Write-Output "Error : "$_.ErrorDetails.Message
  Write-Output "Command : "$_.InvocationInfo.Line
}
#ds-snippet-end:Rooms9Step5
