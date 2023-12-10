# IntuneProactiveRemediations
![GitHub License](https://img.shields.io/github/license/dylanmccrimmon/IntuneProactiveRemediations)
![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/dylanmccrimmon/IntuneProactiveRemediations/test-proactive-remediations-repository.yml?label=Proactive%20Remediations%20Repository%20Tests)

This repository contains scripts for Microsoft Intune Proactive Remediations.

To import a Microsoft Intune Proactive Remediations, clone this repository and run the ```Import-ProactiveRemediation.ps1``` script from the tools directory.

To add a Microsoft Intune Proactive Remediation, fork this repository, add in your Proactive Remediations by using the ```New-ProactiveRemediation.ps1``` script and submit a pull request.

## Scripts & Tools
There are a few Powershell script that can help with building, adding & validating a Proactive Remediations.

- To import a Proactive Remediations to your Intune environment use the ```Import-ProactiveRemediation.ps1``` script.
- To create a Proactive Remediations, use the ```New-ProactiveRemediation``` script.
- To test if the Proactive Remediations Repository is vaild, use the ```Test-ProactiveRemediationRepository``` script.

## Proactive Remediation File & Folder Standards
Proactive Remediations should be added in the following folder structure
```Repository\<Name of Proactive Remediation without whitespace>```

The folder should contain the following files:
- Detection.ps1
- Remediation.ps1
- ProactiveRemediation.json

The `ProactiveRemediation.json` file should contain the following properties.
```json
{
    "displayName": "string",
    "description": "string",
    "publisher": "string",
    "runAsAccount": "string",
    "runAs32Bit": true,
    "enforceSignatureCheck": true
}
```

If additional properties are added, these will not be imported into Microsoft Intune.

## Issues
If you have an issue, please raise a Github issue. When creating a issue, please add as much information as possible (code snippets, error messages, etc).

## Authors and acknowledgment
This project uses the following Powershell modules:
- [MSAL.PS](https://github.com/AzureAD/MSAL.PS/)
- [Microsoft.Powershell.ConsoleGuiTools](https://github.com/PowerShell/GraphicalTools/)

## License
This project is licensed under the Apache License 2.0. For more information on the Apache License 2.0 , please read the [LICENSE](LICENSE) file.