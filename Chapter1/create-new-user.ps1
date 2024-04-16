# Define the user details
$displayname = "IntuneUser One"
$givenname = "IntuneUser"
$surname = "One"
$usageLocation = "GB"
$mailNickname = "intuneuser1"
$password = "Trick@1234"
$domainname = "03z3s.onmicrosoft.com"

# Define the JSON for the new user
$json = @"
{
    "accountEnabled": true,
    "displayName": "$displayname",
    "givenName": "$givenname",
    "mailNickname": "$mailNickname",
    "passwordProfile": {
        "forceChangePasswordNextSignIn": true,
        "password": "$password"
    },
    "surname": "$surname",
    "usageLocation": "$usageLocation",
    "userPrincipalName": "$mailnickname@$domainname"
}
"@

# Define the URI for creating a new user
$uri = "https://graph.microsoft.com/beta/users"

# Send the new user details to Microsoft Graph
Write-Host "Creating new user"
Invoke-MgGraphRequest -Method POST -Uri $uri -Body $json -ContentType "application/json"
Write-Host "User created successfully"