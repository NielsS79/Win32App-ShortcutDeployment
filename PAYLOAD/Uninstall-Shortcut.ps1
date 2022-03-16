Try {
    Import-Module .\Shortcuts.psm1 -Force; # Remove -Force before flight.
    $config = (Get-Content -Path '.\shortcut.json' | Out-String | ConvertFrom-Json);
    Remove-IconFile -Name $config.Name;
    $outputPaths = Get-OutputLocations -StartMenu:$config.Location.StartMenu -Desktop:$config.Location.Desktop -StartMenuFolder $config.Location.StartMenuFolder -AllUsers:$config.Location.AllUsers;
    $outputPaths | Remove-ShortcutFile -Name $config.Name;
    if ($config.VersionMarker) {
        Remove-VersionMarker -Name "$($config.StartMenuFolder)$($config.Name)";
    }
    Exit 0; 
} 
Catch {
    Exit 1; 
}    