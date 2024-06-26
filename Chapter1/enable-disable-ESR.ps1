# Set to 2 to disable or 0 to enable
$esrstatus = 2
$tenantid = "b5683b08-cb53-45a8-b4ff-1531a0ed2f38"

# Define the JSON for the ESR status
$json = @"
{
    "isAdminConfigurable": true,
    "isRoamingSettingChanged": true,
    "syncSelectedUsers": [],
    "syncSetting": $esrstatus
}
"@

# Define the URL for the ESR status
$url = "https://main.iam.ad.ext.azure.com/api/RoamingSettings?ESRV2=true"


# Create Access Token
$clientid = "1950a258-227b-4e31-a9cf-717495945fc2"

# Request the device code for authentication
Write-Host "Requesting device code for authentication"
$response = Invoke-RestMethod -Method POST -UseBasicParsing -Uri "https://login.microsoftonline.com/$tenantId/oauth2/devicecode" -ContentType "application/x-www-form-urlencoded" -Body "client_id=$clientId"
Write-Host $response.message

# Initialize the wait time
$waited = 0

# Start a loop to continuously try for authentication
while($true){
    try{
        # Attempt to get the authentication response
        Write-Host "Attempting to get authentication response"
        $authResponse = Invoke-RestMethod -uri "https://login.microsoftonline.com/$tenantId/oauth2/token" -ContentType "application/x-www-form-urlencoded" -Method POST -Body "grant_type=device_code&code=$($response.device_code)&client_id=$clientId" -ErrorAction Stop
        $refreshToken = $authResponse.refresh_token
        break
    }catch{
        # If no valid login is detected within 5 minutes, throw an error
        if($waited -gt 300){
            Write-Host "No valid login detected within 5 minutes"
            Throw
        }
        # Wait for 5 seconds before trying again
        Start-Sleep -s 5
        $waited += 5
    }
}

# Get the resource token
Write-Host "Getting resource token"
$response = (Invoke-RestMethod "https://login.windows.net/$tenantId/oauth2/token" -Method POST -Body "resource=74658136-14ec-4630-ad9b-26e160ff0fc6&grant_type=refresh_token&refresh_token=$refreshToken&client_id=$clientId&scope=openid" -ErrorAction Stop)
$resourceToken = $response.access_token

# Define the headers for the request
$Headers = @{
    "Authorization" = "Bearer " + $resourceToken
    "Content-type"  = "application/json"
    "X-Requested-With" = "XMLHttpRequest"
    "x-ms-client-request-id" = [guid]::NewGuid()
    "x-ms-correlation-id" = [guid]::NewGuid()
}

# Send the request to the specified URL
Write-Host "Sending request to the specified URL"
Invoke-RestMethod -Uri $url -Headers $Headers -Method PUT -Body $json -ErrorAction Stop
Write-Host "Request sent successfully"




