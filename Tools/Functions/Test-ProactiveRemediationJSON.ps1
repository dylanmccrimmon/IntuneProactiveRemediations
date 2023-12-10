Function Test-ProactiveRemediationJSON {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Check if the json is importable
    try {
        $json = Get-Content -Path $Path -Raw -ErrorAction Stop | ConvertFrom-Json
    }
    catch {
        Write-Warning -Message "The file '$Path' is not a valid JSON file"
        return $false
    }

    # Check if the json has the required properties
    $RequiredProperties = @(
        'displayName',
        'description',
        'publisher',
        'runAsAccount',
        'runAs32Bit',
        'enforceSignatureCheck'
    )

    # Loop through and check if the json has the required properties
    foreach ($RequiredProperty in $RequiredProperties) {
        if (-not $json.PSObject.Properties.Name.Contains($RequiredProperty)) {
            Write-Warning -Message "The file '$Path' is missing the required property '$RequiredProperty'"
            return $false
        }
    }

    # ToDo: Check data types of the properties

    # All checks passed
    return $true
}