Try {
    Import-Module .\Shortcuts.psm1 -Force; # Remove -Force before flight.
    $config = (Get-Content -Path '.\shortcut.json' | Out-String | ConvertFrom-Json);
    $iconFile = Copy-IconFile -Name "$($config.StartMenuFolder)$($config.Name)"; 
    $outputPaths = Get-OutputLocations -StartMenu:$config.Location.StartMenu -Desktop:$config.Location.Desktop -StartMenuFolder $config.Location.StartMenuFolder -AllUsers:$config.Location.AllUsers;
    $outputPaths | New-ShortcutFile -Name $config.Name -Description $config.Description -Target $config.Target.Program -Arguments $config.Target.Arguments -WorkingDirectory $config.Target.WorkingDirectory -IconFile $iconFile;
    if ($config.VersionMarker) {
        Set-VersionMarker -Name "$($config.StartMenuFolder)$($config.Name)";
    }
    Exit 0; 
} 
Catch {
    Exit 1; 
}