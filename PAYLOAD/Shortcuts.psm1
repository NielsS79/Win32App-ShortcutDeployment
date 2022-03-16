Function Get-OutputLocations {
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Enable publication in the start menu.')]
            [switch]$StartMenu,
        [Parameter(Mandatory=$false, HelpMessage='Enable publication on the desktop.')]
            [switch]$Desktop,
        [Parameter(Mandatory=$false, HelpMessage='Enter a subfolder to use when publishing in start menu.')]
            [string]$StartMenuFolder = $null,
        [Parameter(Mandatory=$false, HelpMessage='Use the all users variant(s).')]
            [switch]$AllUsers
    )
        
    # Prepare current user shortcut locations.
    $desktopPath = [Environment]::GetFolderPath("Desktop"); 
    $startMenuPath = [Environment]::GetFolderPath("Programs"); # This is the Programs-folder inside the StartMenu-path.
    if ($AllUsers) {
        # Override shortcut locations with _all users_ variants, if requested.
        $desktopPath = [Environment]::GetFolderPath("CommonDesktop");
        $startMenuPath = [Environment]::GetFolderPath("CommonPrograms");
    }

    # Prepare shortcut locations for output.
    $shortcutPaths = @();
    if ($Desktop) {
        $shortcutPaths += $desktopPath;
    }
    if ($StartMenu) {
        if ($StartMenuFolder) {
            $startMenuPath += "\$($StartMenuFolder)";        
        }
        # Create the subfolder if it doesn't exist. 
        if (-not(Test-Path $startMenuPath)) {
            New-Item -Path $startMenuPath -ItemType Directory | Out-Null;
        }
        $shortcutPaths += $startMenuPath;
    }
    return $shortcutPaths; 
}

Function New-ShortcutFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, HelpMessage='Enter the name (without extension).')]
            [string]$Name,
        [Parameter(Mandatory=$false, HelpMessage='Enter a description.')]
            [string]$Description='',
        [Parameter(Mandatory=$true, HelpMessage='Enter the target (program).')]
            [string]$Target,
        [Parameter(Mandatory=$false, HelpMessage='Enter the target arguments to call.')]
            [string]$Arguments=$null,
        [Parameter(Mandatory=$false, HelpMessage='Enter the working directory (path).')]
            [string]$WorkingDirectory=$null,
        [Parameter(Mandatory=$false, HelpMessage='Enter a path to an icon file (.ico).')]
            [string]$IconFile=$null,
        [Parameter(ValueFromPipeline, Mandatory=$true, HelpMessage='Enter the path where the shortcut should be placed.')]
            [string]$OutputPath
    )

    # Create shortcut. 
    $outputFile = "$OutputPath\$($Name).lnk";
    $sh = New-Object -ComObject WScript.Shell;
    $shortcut = $sh.CreateShortcut($outputFile);
    $shortcut.Description = $Description;
    $shortcut.TargetPath = $Target;
    $shortcut.Arguments = $Arguments;
    $shortcut.WorkingDirectory = $WorkingDirectory; 
    if ($IconFile) {
        $shortcut.IconLocation = $IconFile;
    }
    $shortcut.Save();
    $sh = $null; 
    return $null;
}

Function Remove-ShortcutFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, HelpMessage='Enter the name (without extension).')]
            [string]$Name,
        [Parameter(ValueFromPipeline, Mandatory=$true, HelpMessage='Enter the path where the shortcut should be removed.')]
            [string]$OutputPath
    )
    $outputFile = "$OutputPath\$($Name).lnk";    
    if (Test-Path -Path $outputFile -PathType Leaf) {
        Remove-Item -Path $outputFile -Force | Out-Null;
    }
    return $null; 
}

Function Copy-IconFile {
    Param(
        [Parameter(Mandatory=$true, HelpMessage='Enter the base (file)name (without extension).')]
            [string]$Name,
        [Parameter(Mandatory=$false, HelpMessage='Enter the foldername to use for local storage (in %ProgramData%).')]
            [string]$RepositoryName='ThreeIsACloud'
    )    

    # If there's an icon in the payload, put a copy in our local repository.
    if (Test-Path '.\icon.ico') {         
        $iconPath = "$(Get-RepositoryPath -RepositoryName $RepositoryName)\Icons";
        if (-not(Test-Path -Path $iconPath)) {
            New-Item -Path $iconPath -ItemType Directory | Out-Null;
        }
        $iconPath = "$iconPath\$($Name).ico";
        Copy-Item -Path '.\icon.ico' -Destination $iconPath -Force | Out-Null;                
        return $iconPath; 
    }
    return $null; 
}

Function Remove-IconFile {
    Param(
        [Parameter(Mandatory=$true, HelpMessage='Enter the base (file)name (without extension).')]
            [string]$Name,
        [Parameter(Mandatory=$false, HelpMessage='Enter the foldername to use for local storage (in %ProgramData%).')]
            [string]$RepositoryName='ThreeIsACloud'
    )    

    $iconPath = "$(Get-RepositoryPath -RepositoryName $RepositoryName)\Icons\$($Name).ico";    
    if (Test-Path -Path $iconPath -PathType Leaf) {
        Remove-Item -Path $iconPath -Force | Out-Null;
    }
    return $null; 
}

Function Get-RepositoryPath {
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Enter the foldername to use for local storage (in %ProgramData%).')]
            [string]$RepositoryName='ThreeIsACloud'    
    )
    return "$($env:programdata)\$RepositoryName";
}

Function Set-VersionMarker {
    Param(
        [Parameter(Mandatory=$true, HelpMessage='Enter the base (file)name for this marker. Do not enter a file extension.')]
            [string]$Name,
        [Parameter(Mandatory=$false, HelpMessage='Enter the content to put in the marker file.')]            
            [string]$CustomBody=(Get-Date -Format 'yyyyMMdd-HHmmss'),                    
        [Parameter(Mandatory=$false, HelpMessage='Enter the foldername to use for local storage (in %ProgramData%).')]
            [string]$RepositoryName='ThreeIsACloud'
    )       

    # Prepare location. 
    $markerPath = "$(Get-RepositoryPath -RepositoryName $RepositoryName)\VersionMarkers";
    if (-not(Test-Path -Path $markerPath)) {
        New-Item -Path $markerPath -ItemType Directory | Out-Null;
    }
    $markerPath = "$markerPath\$($Name).txt";        

    # Set the marker. 
    Set-Content -Path $markerPath -Value $CustomBody; 
    return $null;
}

Function Remove-VersionMarker {
    Param(
        [Parameter(Mandatory=$true, HelpMessage='Enter the base (file)name for this marker. Do not enter a file extension.')]
            [string]$Name,        
        [Parameter(Mandatory=$false, HelpMessage='Enter the foldername to use for local storage (in %ProgramData%).')]
            [string]$RepositoryName='ThreeIsACloud'
    ) 
    $markerPath = "$(Get-RepositoryPath -RepositoryName $RepositoryName)\VersionMarkers\$($Name).txt";
    if (Test-Path -Path $markerPath -PathType Leaf) {
        Remove-Item -Path $markerPath -Force | Out-Null;
    } 
    return $null; 
}

# Export all the things!
Export-ModuleMember -Function *;