# Win32App-ShortcutDeployment
This collection of scripts will enable you to install _and_ uninstall shortcuts to the user's (or All User's / Public) Desktop or Start Menu as if it were a Win32-app. For the story behind this solution, please visit https://threeisacloud.tech/shortcut-provisioning/. Why yes, that _is_ my blog :blush:. 
 
## Configuring a package
This solution was made with easy configuration in mind. You do not need to edit _any_ PowerShell scripts to use it. The only this you need to change is the `shortcut.json` file in the `PAYLOAD` folder. This JSON-formatted file contains all the configurable values for a shortcut. 

- **Name:** the (file)name the shortcut will receive.
- **Description:** this text will be entered in the file's Description attribute.
- **Target.Program:** the program the shortcut will point to. 
- **Target.Arguments:** the arguments the shortcut will use when executing Target.Program.
- **Target.WorkingDirectory:** the directory Target.Program will be executed in. 
- **Location.StartMenu:** enable publication of the shortcut in the Start Menu. 
- **Location.StartMenuFolder:** (optionally) use a subfolder for publication in the Start Menu. 
- **Location.Desktop:** enable publication of the shortcut on the Desktop. 
- **Location.AllUsers:** switch to the All Users / Public equivalent of Start Menu and Desktop. 
- **VersionMarker:** create a version marker file you can use in detection rules. 

## Adding an icon
If you wish to set a custom icon, all you need to do is place an ``icon.ico`` file in the ``PAYLOAD`` folder. It will be picked up automatically.

## Checking your package's configuration
For your convenience a sanity check is included. You can validate your configuration with the following command:
```Cmd
.\Check-ShortcutConfig.ps1
```

This will check the sanity of the ``shortcut.json`` file in the ``PAYLOAD`` folder. 
If you configuration enables the ``VersionMarker`` option, it will also give you a hint on the detection rule you can use. 

## Creating the package
The files in the ``PAYLOAD`` folder should be packaged with "Microsoft's Win32 Content Prep Tool" (https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool). Please make sure this tool is available on your system. In the example below we assume it's in the solution's root folder, like this README.md. 

The following command create a package in the current directory.
```Cmd
.\IntuneWinAppUtil -c .\PAYLOAD -s shortcut.json -o .\
```

Please note that IntuneWinAppUtil _requires_ the setup-file to be specified. As this file also _must_ exist within your package, I used ``shortcut.json``. 
As far as I can tell it's only used to generate an output filename and as the app's name/description in the package's metadata. These can be renamed/overruled, so don't worry about it. 

## Using the package in Microsoft Endpoint Manager
To use this package, perform the following in MEM. Configure any unspecified items to suit your needs. 

- Create a new app of type "Windows app (Win32)".
- Select and upload the package you created earlier.
- Optionally, (but please do) change the app's name and description (these will be preconfigured as "shortcut.json").
- Use the following "Install command": ``powershell.exe -ExecutionPolicy Bypass -File Install-Shortcut.ps1``.
- Use the following "Uninstall command": ``powershell.exe -ExecutionPolicy Bypass -File Uninstall-Shortcut.ps1``.
- Set "Install behavior" to "System".

*If you are using the ``VersionMarker`` option, add the corresponding detection rule. Run ``Check-ShortcutConfig.ps1`` if you're not sure what to enter.*

You can now use this just like any other app. Assign groups to install or uninstall as you wish.

## Updating the shortcut with the "VersionMarker" option
If you configured the app with this option, you can update the shortcut(s) by editing the app existing app. 

- Upload your new package. 
- Update the date/time value in the existing detection rule. 

That's all there is to it. 
