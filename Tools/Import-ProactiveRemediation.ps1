#Requires -Modules MSAL.PS

param(
    [Parameter(Mandatory = $false)]
    [string]$Path = "$((Get-Location).path)/Repository",

    [Parameter(Mandatory = $false)]
    [string]$Name
)

# Import the Test-ProactiveRemediationJSON function
. "$PSScriptRoot/Functions/Test-ProactiveRemediationJSON.ps1"

# Import the Test-ProactiveRemediationDirectory function
. "$PSScriptRoot/Functions/Test-ProactiveRemediationDirectory.ps1"

# Get all folders recursively
$folders = Get-ChildItem -Path $Path -Directory -Recurse

# Array to store the valid Proactive Remediations
$VaildProactiveRemediations = @()

# Loop through each folder
foreach ($folder in $folders) {

    # Check if the folder is valid
    if (!(Test-ProactiveRemediationDirectory -Path $folder.FullName)) {
        Write-Warning -Message "The folder '$folder' is not a valid Proactive Remediation folder"
        break
    }

    # Check if the folder has a valid ProactiveRemediation.json
    if (!(Test-ProactiveRemediationJSON -Path "$($folder.FullName)\ProactiveRemediation.json")) {
        Write-Warning -Message "The folder '$folder' has an invalid ProactiveRemediation.json"
        break 
    }

    # Get the ProactiveRemediation.json
    $ProactiveRemediationJson = Get-Content -Path "$($folder.FullName)\ProactiveRemediation.json" -Raw | ConvertFrom-Json

    # Build a object with the required properties
    $ProactiveRemediationObject = [PSCustomObject]@{
        'Name' = $ProactiveRemediationJson.displayName
        'Description' = $ProactiveRemediationJson.description
        'Version' = $ProactiveRemediationJson.version
        'Publisher' = $ProactiveRemediationJson.publisher
        'Path' = $folder.FullName
    }

    # Add the object to the array
    $VaildProactiveRemediations += $ProactiveRemediationObject
}

# Check if there are any valid Proactive Remediations
if ($VaildProactiveRemediations.Count -eq 0) {
    Write-Error -Message "No valid Proactive Remediations found"
    break
}

# If a name was specified, filter the Proactive Remediations
if ($Name) {
    $UserSelection = $VaildProactiveRemediations | Where-Object {$_.Name -like "$Name"}

    # Check if the Proactive Remediation was found
    if (-not $UserSelection) {
        Write-Error -Message "No vaild Proactive Remediation found with the name '$Name'"
        break
    }

} else {
    # Import the Out-ConsoleGridView function
    Add-Type -Path "$((Get-Location).path)/Tools/.bin/Modules/Microsoft.PowerShell.ConsoleGuiTools/0.7.6.0/Microsoft.PowerShell.ConsoleGuiTools.dll"
    Add-Type -Path "$((Get-Location).path)/Tools/.bin/Modules/Microsoft.PowerShell.ConsoleGuiTools/0.7.6.0/Terminal.Gui.dll"

    # Show and prompt the user to select a Proactive Remediation
    $UserSelection = $VaildProactiveRemediations | Select-Object -ExcludeProperty "Path" | Sort-Object -Property Name -Descending | Out-ConsoleGridView -Title 'Select a Proactive Remediation' -OutputMode Single
}

# Check if the user selected a Proactive Remediation
if ($UserSelection) {

    # Get the selected Proactive Remediation
    $UserSelection = $VaildProactiveRemediations | Where-Object {$_.Name -eq $UserSelection.Name}

    # Get the Detection script in base64 format
    $DetectionScript = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path "$($UserSelection.Path)\Detection.ps1" -Raw)))

    # Get the Remediation script in base64 format
    $RemediationScript = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path "$($UserSelection.Path)\Remediation.ps1" -Raw)))

    # Import the Proactive Remediation JSON
    $ProactiveRemediationJson = Get-Content -Path "$($UserSelection.Path)\ProactiveRemediation.json" -Raw | ConvertFrom-Json

    # Build the Proactive Remediation JSON
    $ProactiveRemediation = [PSCustomObject]@{
        '@odata.type' = "#microsoft.graph.deviceHealthScript"
        'displayName' = $ProactiveRemediationJson.displayName
        'description' = $ProactiveRemediationJson.Description
        'version' = $ProactiveRemediationJson.Version
        'publisher' = $ProactiveRemediationJson.Publisher
        'runAsAccount' = $ProactiveRemediationJson.runAsAccount
        'runAs32Bit' = $ProactiveRemediationJson.runAs32Bit
        'enforceSignatureCheck' = $ProactiveRemediationJson.enforceSignatureCheck
        'detectionScriptContent' = $DetectionScript
        'remediationScriptContent' = $RemediationScript
    }

    # Get Microsoft Graph token
    $connectionDetails = @{
        'ClientId'    = 'c3c9a24f-5839-4a33-bb1a-13f4baf874d5'
        'Interactive' = $true
        'RedirectUri' = "urn:ietf:wg:oauth:2.0:oob"
    }
    $token = Get-MsalToken @connectionDetails

    # Create the request headers
    $Headers = @{
        'Authorization' = "Bearer $($token.AccessToken)"
        'Content-Type' = 'application/json'
    }

    # Create the request
    try {
        $Request = @{
            'Uri' = "https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts"
            'Method' = 'POST'
            'Headers' = $Headers
            'Body' = $ProactiveRemediation | ConvertTo-Json -Depth 10
            'ErrorAction' = 'Stop'
            'Verbose' = $false
        }
        $Response = Invoke-RestMethod @Request
    }
    catch {
        Throw "Failed to invoke Graph API request. Error: $($_.Exception.Message)"
    }

    # Check if the request was successful
    if ($Response) {
        Write-Output "Proactive Remediation '$($UserSelection.Name)' was successfully imported"
    } else {
        Write-Error "Failed to import Proactive Remediation '$($UserSelection.Name)'"
    }

} else {
    Write-Output "No Proactive Remediation selected"
}