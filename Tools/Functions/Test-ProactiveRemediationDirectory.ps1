Function Test-ProactiveRemediationDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Write-Verbose -Message "Testing the folder '$Path'"

    # Mandatory files
    $MandatoryFiles = @(
        'Detection.ps1'
        'Remediation.ps1'
        'ProactiveRemediation.json'
    )

    # Get files in the folder
    Write-Verbose -Message "Getting files in the folder '$Path'"
    $files = Get-ChildItem -Path $Path -File

    # Check if the folder has all the mandatory files
    foreach ($MandatoryFile in $MandatoryFiles) {
        Write-Verbose -Message "Checking if the folder has the mandatory file '$MandatoryFile'"
        if (-not $files.Name.Contains($MandatoryFile)) {
            Write-Warning "The folder '$folder' is missing the mandatory file '$MandatoryFile'"
            return $false
        }
    }

    # All checks passed
    Write-Verbose -Message "All checks passed"
    return $true
}