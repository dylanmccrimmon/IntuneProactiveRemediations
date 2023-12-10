function Get-ActivationStatus {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DNSHostName = $Env:COMPUTERNAME
    )
    process {
        try {
            $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $Env:COMPUTERNAME `
                -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
                -Property LicenseStatus -ErrorAction Stop
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null 
        }
        $out = New-Object psobject -Property @{
            ComputerName = $DNSHostName;
            Status       = [string]::Empty;
        }
        if ($wpa) {
            :outer foreach ($item in $wpa) {
                switch ($item.LicenseStatus) {
                    0 { $out.Status = "Unlicensed" }
                    1 { $out.Status = "Licensed"; break outer }
                    2 { $out.Status = "Out-Of-Box Grace Period"; break outer }
                    3 { $out.Status = "Out-Of-Tolerance Grace Period"; break outer }
                    4 { $out.Status = "Non-Genuine Grace Period"; break outer }
                    5 { $out.Status = "Notification"; break outer }
                    6 { $out.Status = "Extended Grace"; break outer }
                    default { $out.Status = "Unknown value" }
                }
            }
        } else { $out.Status = $status.Message }
        $out
    }
}


try {

    $LicStatus = Get-ActivationStatus

    if ($LicStatus[0].Status -ne 'Licensed') {
        if ( $(Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey ) {
            $(Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey | ForEach-Object { 
                if ( $null -ne $_ ) { 
                    $Key = $_
                    Write-Output "Installing digital license key ($Key)"; 
                    Start-Process -FilePath  "C:\Windows\System32\changepk.exe" -ArgumentList "/Productkey $Key" -WindowStyle Hidden
                    Start-Process -FilePath "C:\Windows\System32\cscript.exe" -ArgumentList "C:\Windows\System32\slmgr.vbs /ipk $Key" -Wait -WindowStyle Hidden
                    Start-Process -FilePath "C:\Windows\System32\cscript.exe" -ArgumentList "C:\Windows\System32\slmgr.vbs /ato" -Wait -WindowStyle Hidden
                    Write-Output "Digital license key installed ($Key)"
                    exit 0
                } else {
                    Write-Output "No digital license key present"
                    exit 1
                } 
            }
        }
    }

} catch {
    
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1

}