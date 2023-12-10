param (
    [Parameter(Mandatory = $false)]
    [string]$RepositoryPath = "$((Get-Location).path)/Repository"
)

# Import the Test-ProactiveRemediationJSON function
. "$PSScriptRoot/Functions/Test-ProactiveRemediationJSON.ps1"

# Import the Test-ProactiveRemediationDirectory function
. "$PSScriptRoot/Functions/Test-ProactiveRemediationDirectory.ps1"

# Get all folders in the repository
Write-Verbose -Message "Getting all folders in the repository"
$folders = Get-ChildItem -Path $RepositoryPath -Directory

# Loop through all folders
foreach ($folder in $folders) {
    Write-Verbose -Message "Testing the folder '$($folder.Name)'"

    if (!(Test-ProactiveRemediationDirectory -Path $folder.FullName)) {
        Write-Warning -Message "The folder '$($folder.Name)' is not a valid Proactive Remediation folder"
        $TestFailed = $true
        continue
    }

    if (!(Test-ProactiveRemediationJSON -Path "$(Join-Path -Path $folder.FullName -ChildPath "ProactiveRemediation.json")")) {
        Write-Warning -Message "The folder '$($folder.Name)' is not a valid Proactive Remediation folder"
        $TestFailed = $true
        continue
    }
}

if ($TestFailed) {
    Throw "One or more folders are not valid"
} else {
    Write-Output -Message "All folders are valid Proactive Remediation"
}