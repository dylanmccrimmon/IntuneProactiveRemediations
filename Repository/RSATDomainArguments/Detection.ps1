function Get-Shortcut {
    param(
        $path = $null
    )

    $obj = New-Object -ComObject WScript.Shell

    if ($path -eq $null) {
        $pathUser = [System.Environment]::GetFolderPath('StartMenu')
        $pathCommon = $obj.SpecialFolders.Item('AllUsersStartMenu')
        $path = dir $pathUser, $pathCommon -Filter *.lnk -Recurse 
    }
    if ($path -is [string]) {
        $path = dir $path -Filter *.lnk
    }
    $path | ForEach-Object { 
        if ($_ -is [string]) {
        $_ = dir $_ -Filter *.lnk
        }
        if ($_) {
        $link = $obj.CreateShortcut($_.FullName)

        $info = @{}
        $info.Hotkey = $link.Hotkey
        $info.TargetPath = $link.TargetPath
        $info.LinkPath = $link.FullName
        $info.Arguments = $link.Arguments
        $info.Target = try {Split-Path $info.TargetPath -Leaf } catch { 'n/a'}
        $info.Link = try { Split-Path $info.LinkPath -Leaf } catch { 'n/a'}
        $info.WindowStyle = $link.WindowStyle
        $info.IconLocation = $link.IconLocation

        New-Object PSObject -Property $info
        }
    }
}
function Set-Shortcut {
    param(
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $LinkPath,
    $Hotkey,
    $IconLocation,
    $Arguments,
    $TargetPath
    )
    begin {
        $shell = New-Object -ComObject WScript.Shell
    }

    process {
        $link = $shell.CreateShortcut($LinkPath)

        $PSCmdlet.MyInvocation.BoundParameters.GetEnumerator() |
        Where-Object { $_.key -ne 'LinkPath' } |
        ForEach-Object { $link.$($_.key) = $_.value }
        $link.Save()
    }
}
  
# Get Primary DNS Suffix
$PrimaryDNSSuffix = (Get-DnsClientGlobalSetting).SuffixSearchList[0]

# Check if there is a Primary DNS Suffix
if ($null -eq $PrimaryDNSSuffix) {
    Write-Output 'A primary DNS suffix is not set on the device however RSAT tools are installed. Script cannot update shortcuts without a primary DNS suffix. Exiting 1'
    Exit 0
}

# Get supported RSAT shortcuts
$RSATShortcuts = @('Active Directory Sites and Services.lnk', 'Active Directory Users and Computers.lnk')
$RSATShortcuts = Get-ChildItem -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools' | Where-Object {$_.Name -in $RSATShortcuts}

if ($RSATShortcuts.Count -ge 1) {

    Write-Output "One or more supported RSAT tool shortcuts found."

    foreach ($RSATShortcut in $RSATShortcuts) {

        $ShortcutDetails = Get-Shortcut $RSATShortcut.FullName

        if (!$ShortcutDetails.Arguments.Contains("/domain=$PrimaryDNSSuffix")) {

            Write-Output "One or more supported RSAT tool shortcuts require an argument list update. Exiting 1"
            Exit 1
        }
        
    }
    
} else {

    Write-Output "No supported RSAT tool shortcuts found. Exiting 0"
    Exit 0

}