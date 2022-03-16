# MEMShortcutDeployment
This collection of scripts and other data will enable you to install _and_ uninstall shortcuts to the user's (or All User's) Desktop or Start Menu. For the story behind the creation of this solution, please visit https://threeisacloud.tech/cutting-it-short/. 

## Configuring a package
This solution was made with easy configuration in mind. You do not need to edit _any_ PowerShell script. The only this we need to change is the `shortcut.json` file in the `PAYLOAD` folder, which is of course a JSON-formatted textfile. It contains all the configurable values for a shortcut. 

- **Name:** the (file)name the shortcut will receive.
- **Description:** this text will be entered in the file's Desription attribute.
- **Target.Program:** the program the shortcut will point to. 
- **Target.Arguments:** the arguments the shortcut will use when executing Target.Program.
- **Target.WorkingDirectory:** the directory Target.Program will be executed in. 
- **Location.StartMenu:** enable publication of the shortcut in the Start Menu. 
- **Location.StartMenuFolder:** (optionally) use a subfolder for publication in the Start Menu. 
- **Location.Desktop:** enable publication of the shortcut on the Desktop. 
- **Location.AllUsers:** switch to the All Users equivalent of Start Menu and Desktop. 
- **VersionMarker:** create a version marker file you can use in detection rules. 

## Adding an icon
If you wish to set a custom icon, all you need to do is place an ``icon.ico`` file in the ``PAYLOAD`` folder.

## Checking your package's configuration
For your convenience a sanity check is included. You can validate your configuration with the following command:
```Cmd
.\Check-ShortcutConfig.ps1
```

This will check the sanity of the ``shortcut.json`` file in the ``PAYLOAD`` folder. 
If you configuration enables the ``VersionMarker`` option, it will also give you a hint on the detection rule you can use. 

## Creating the package
The files in the ``PAYLOAD`` folder should be packaged with "Microsoft's Win32 Content Prep Tool" (https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool). Please make sure this tool is available on your system. In the example below we assume it's in the solutions root folder, like this README.md. 

The following command create a package in the current directory.
```Cmd
.\IntuneWinAppUtil -c .\PAYLOAD -s shortcut.json -o .\
```

Please note that IntuneWinAppUtil _requires_ the setup-file to be specified. As far as I can tell it's only used to generate an output filename (and as the app name, but you can overrule that). However, as it _must_ exist, I used ``shortcut.json`` which results in the outut filename ``shortcut.intunewin``. Feel free to rename it to your liking afterwards.

## Using the package in Microsoft Endpoint Manager
To use this package, perform the following in MEM. Configure any unspecified items to suit your needs. 

- Create a new app of type "Windows app (Win32)".
- Select and upload the package you created earlier.
- Optionally, (but please do) change the app's name and description (these will be preconfigured as "shortcut.json").
- Use the following "Install command": ``powershell.exe -ExecutionPolicy Bypass -File Install-Shortcut.ps1``.
- Use the following "Uninstall command": ``powershell.exe -ExecutionPolicy Bypass -File Uninstall-Shortcut.ps1``.
- Set "Install behavior" to "System".

*If you are using the ``VersionMarker`` option, add the corresponding detection rule. Run ``Check-ShortcutConfig.ps1`` if you're not sure what to enter.*

You can now use this as a 'normal' app to install or uninstall as you wish.

## Updating the shortcut with the "VersionMarker" option
If you configured the app with this option, you can update the shortcut(s) by editing the app existing app. 

- Upload your new package. 
- Update the date/time value in the existing detection rule. 

Existing deployments will now no longer detect a valid app installation and re-run the "Install command" with the updated payload. 
