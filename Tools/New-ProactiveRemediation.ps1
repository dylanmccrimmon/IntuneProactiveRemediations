# Example: ./New-ProactiveRemediation.ps1 -Name 'Example Proactive Remediation' -Description 'This is an example Proactive Remediation' -Publisher 'Example Publisher' -RunAsAccount 'system' -RunAs32Bit $true -EnforceSignatureCheck $true -DetectionScriptPath '/Users/dylanm/Library/Mobile Documents/com~apple~CloudDocs/Projects/IntuneProactiveRemediations/DigitalLicense/Detection.ps1' -RemediationScriptPath '/Users/dylanm/Library/Mobile Documents/com~apple~CloudDocs/Projects/IntuneProactiveRemediations/DigitalLicense/Remediation.ps1'

param(
    [Parameter(Mandatory = $false)]
    [string]$RepositoryPath = "$((Get-Location).path)/Repository",

    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter(Mandatory = $false)]
    [string]$Description,

    [Parameter(Mandatory = $true)]
    [string]$Publisher,

    [Parameter(Mandatory = $true)]
    [ValidateSet('system', 'user')]
    [string]$RunAsAccount,

    [Parameter(Mandatory = $true)]
    [bool]$RunAs32Bit,

    [Parameter(Mandatory = $true)]
    [bool]$EnforceSignatureCheck,

    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_})]
    [string]$DetectionScriptPath,

    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_})]
    [string]$RemediationScriptPath
)

# Validate the name parameter - Max 64 characters
if ($Name.Length -gt 64) {
    Throw "The Name parameter can only contain 64 characters"
    return
}

# Validate the name parameter - Allowed characters: a-z, A-Z, 0-9, _, space
if ($Name -notmatch '^[a-zA-Z0-9_ ]+$') {
    Throw "The Name parameter can only contain the following characters: a-z, A-Z, 0-9, _, space"
    return
}

# Validate the description parameter - Max 8192 characters
if ($Description.Length -gt 8192) {
    Throw "The Description parameter can only contain 8192 characters"
    return
}

# Validate the publisher parameter - Max 64 characters
if ($Name.Length -gt 64) {
    Throw "The Name parameter can only contain 64 characters"
    return
}

# Validate the RemdiationScriptPath parameter - Must be a .ps1 file
if ($RemediationScriptPath -notmatch '\.ps1$') {
    Throw "The RemediationScriptPath parameter must be a .ps1 file"
    return
}

# Validate the DetectionScriptPath parameter - Must be a .ps1 file
if ($DetectionScriptPath -notmatch '\.ps1$') {
    Throw "The DetectionScriptPath parameter must be a .ps1 file"
    return
}

# Instantiate required object
$textInfo = (Get-Culture).TextInfo

# Title case the name parameter
$Name = $textInfo.ToTitleCase($Name)

# Title case the publisher parameter
$Publisher = $textInfo.ToTitleCase($Publisher)

# Remove whitespace from the name parameter
$FolderName = $Name.Replace(' ','')

# Create the path for the Proactive Remediation
$ProactiveRemediationPath = Join-Path -Path $RepositoryPath -ChildPath $FolderName

# Check if the folder already exists
if (Test-Path -Path $ProactiveRemediationPath) {
    Throw "The name of the Proactive Remediation already exists. Please specify a different name"
    return
}

# Create folder for the Proactive Remediation
$ProactiveRemediationFolder = New-Item $ProactiveRemediationPath -ItemType Directory -Force

# Create Proactive Remediation JSON object
$ProactiveRemediationJson = [PSCustomObject]@{
    'displayName' = $Name
    'description' = $Description
    'publisher' = $Publisher
    'runAsaccount' = $RunAsAccount
    'runAsis32Bit' = $RunAs32Bit
    'enforceSignatureCheck' = $EnforceSignatureCheck
}

# Export Proactive Remediation JSON object to JSON file
$ProactiveRemediationJson | ConvertTo-Json | Out-File -FilePath "$(Join-Path -Path $ProactiveRemediationFolder -ChildPath "ProactiveRemediation.json")" -Force

# Create Detection.ps1
Copy-Item $DetectionScriptPath -Destination "$(Join-Path -Path $ProactiveRemediationFolder -ChildPath "Detection.ps1")"

# Create Remediation.ps1
Copy-Item $RemediationScriptPath -Destination "$(Join-Path -Path $ProactiveRemediationFolder -ChildPath "Remediation.ps1")"

# Script End
Write-Output "Proactive Remediation created successfully"
Write-Output "Proactive Remediation Name: $Name"
Write-Output "Proactive Remediation Path: $RepositoryPath\$FolderName"