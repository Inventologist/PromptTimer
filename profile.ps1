Write-Host "Loading Powershell Profile" -f Green

#Global
$PSModulePath = Split-Path $profile
$RefreshDependencies = 0

IF ($host.Name -eq 'Windows PowerShell ISE Host') {
    $RefreshDependencies = 1
}

#If you are in ConsoleHost, but NOT in VSCode
IF (($host.name -eq 'ConsoleHost') -AND ($env:TERM_PROGRAM -eq $null)) {
    Start-Sleep -Milliseconds 250
    
    #IF a key is being pressed, force a refresh
    if ([Console]::KeyAvailable) {
        # read the key, and consume it so it won't be echoed to the console:
        $keyInfo = [Console]::ReadKey($true)
        # exit loop
        $RefreshDependencies = 1
    }
}

#If you are in ConsoleHost under VSCode
IF (($host.name -eq 'ConsoleHost') -AND ($env:TERM_PROGRAM -eq 'vscode')) {
    $RefreshDependencies = 1
    }


#Gather Dependencies
IF ($RefreshDependencies -eq 1) {
    #Get-Git PromptTimer
    Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/PromptTimer/archive/master.zip";$GHUser="Inventologist";$GHRepo="PromptTimer";$ForceRefresh="Yes"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
} ELSE {
    #$PathToModule = (Split-Path $profile) + "\Modules\PromptTimer-Inventologist\PromptTimer.psm1"
    Import-Module $PSModulePath\Modules\PromptTimer-Inventologist\PromptTimer.psm1 
}