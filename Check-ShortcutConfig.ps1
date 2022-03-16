Import-Module .\PAYLOAD\Shortcuts.psm1 -Force; # Remove -Force before flight.; 
Write-Host 'Loading configuration from ".\PAYLOAD\shortcut.json"...';
$config = $null;
Try {    
    $config = (Get-Content -Path '.\PAYLOAD\shortcut.json' | Out-String | ConvertFrom-Json);
} 
Catch {
    Write-Host '   NOT OK: ' -ForegroundColor Red -NoNewline;
    Write-Host 'The file could not be parsed as JSON-formatted.';
    Write-Host;
    Write-Host $_.Exception.Message; 
    Write-Host;
    Exit 1;
}

Write-Host 'Checking configured values...';  
$errorsFound = $false;
if (-not($config.Name) -or ($config.Name.Length -le 0)) {
    Write-Host '    NOT OK: ' -ForegroundColor Red -NoNewline;
    Write-Host 'Missing a required value: "Name".';
    $errorsFound = $true;
}
if (-not($config.Target.Program) -or ($config.Target.Program.Length -le 0)) {
    Write-Host '    NOT OK: ' -ForegroundColor Red -NoNewline;
    Write-Host 'Missing a required value: "Target.Program".';
    $errorsFound = $true;
}
if (-not($config.Location.StartMenu) -and -not($config.Location.Desktop)) {
    Write-Host '    NOT OK: ' -ForegroundColor Red -NoNewline;
    Write-Host 'Neither Location.StartMenu or Location.Desktop is set. This configuration would not do anything.';
    $errorsFound = $true;
}
if ($errorsFound) {
    Write-Host;
    Exit 1;
}
Write-Host 'No errors found.';
Write-Host;

if ($config.VersionMarker) {
    $markerPath = "$(Get-RepositoryPath)\VersionMarkers";
    $markerFilename = "$($config.StartMenuFolder)$($config.Name).txt";
    Write-Host 'Generating detection rule based on configuration. Use "Manually configure detection rules" to enter these values.'
    Write-Host '   Rule type:        File';
    Write-Host "   Path:             $markerPath";
    Write-Host "   File or folder:   $markerFilename";
    Write-Host '   Detection method: Date modified';
    Write-Host '   Operator:         Less than or equal to';
    Write-Host "   Value:            $(Get-Date -Format 'MM/dd/yyyy h:mm:ss')";
    Write-Host;
}