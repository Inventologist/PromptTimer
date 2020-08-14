<#
.SYNOPSIS
  Shows you (on your Powershell prompt) the execution time (length) of the last powershell command you ran.
.DESCRIPTION
  Shows you (on your Powershell prompt) the execution time (length) of the last powershell command you ran.
  Once the function finds a suitable format (going from MS (milliseconds) up), it returns, so it should have minimal impact on execution times.
  
.OUTPUTS
  Outputs the execution time of your last command, and it automaticallly switches between 
  millliseconds, seconds, minutes, hours, etc based on how long the command took to run.
  
  Format changes as the execution time gets longer:
    Examples:
    It will not show you: 1340.043435 ms, it will show you: 1.340 sec
    It will not show you: 90.50 sec, it will show you: 1 min 30.5 sec
    Also, when the command goes over 1 Hour, it will show you StartExecutionTime and EndExecutionTime, along
      with a decimal representation of the hours, and the breakdown of Hours, Minutes and Seconds
    No plans yet to do anything when it goes over 24 hours.
   
  Error Handling:
    If the command is cancelled, or exits with an error status, it will display a message on the prompt 
    (no matter what length of execution time)
  Colors:
    As of v1.4, the prompt now has colors.  There are separate lines for the Execution Time and the Current Directory.
    You can set a color for each.  Default is green.
  
.NOTES
  Version:        1.5
  Author:         Ben Therien (Inventologist)
  Creation Date:  2019/08/31

.EXAMPLE
  ## Create or Modify your Powershell profile ##
  To funtion properly, a line to load this must be put into your Powershell Profile.  
  
  If you have never messed with your Powershell profile, there may not even be one yet on your computer.
  To check, at the powershell prompt, type: notepad $profile
  If you don't have one, it will prompt you to CREATE the file.
  When the notepad file comes up, paste the code via one of the methods below into the profile, save, close and then restart powershell.  All set! 
  Method #2 is preferred as it will auto update.

  ## Load Module Method 1 ##
  Download the PromptTimer.psm1 file and put it into a folder named PromptTimer in your Modules directory in your profile.
  Where is the Modules directory in my profile? you may ask...
  I get the Modules directory by using: $PSModulePath = Split-Path $profile + "\Modules"
  Then insert the following Import-Module line into your profile:
  
  Import-Module PromptTimer.psm1
  
  ## Load Module Method 2 ##
  USING Get-Git
  Insert the following Invoke-Expression line into your profile 
  (see ## Create or Modify your Powershell profile ## above if you are unfamiliar with what the Powershell profile is)

  Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/PromptTimer/archive/master.zip";$GHUser="Inventologist";$GHRepo="PromptTimer";$ForceRefresh="Yes"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
  
  If you don't want it to autoupdate everytime you load a powershell window you can use a $host.name filter to stop it from happening if it is in ConsoleHost.
  Or you can simply remove the ;ForceRefresh="Yes" from the Invoke-Expression so it will look like this.

  Invoke-Expression ('$GHDLUri="https://github.com/Inventologist/PromptTimer/archive/master.zip";$GHUser="Inventologist";$GHRepo="PromptTimer"' + (new-object net.webclient).DownloadString('https://raw.githubusercontent.com/Inventologist/Get-Git/master/Get-Git.ps1'))
  
  ## Controlling the Updates more granularly ##
  In the PromptTimer Repo, there is a copy of what my profile looks like (to give you a starting point to give you control over WHEN updates are forced.)
  Mine updates only when in VSCode or ISE, not when in Powershell "Consolehost" ie: running a powershell script.  I did that because I wanted scripts to run faster,

  ENJOY!!
#>

Function PromptTimer {
    $LastCommandRunStats = (Get-History)[-1].EndExecutionTime - (Get-History)[-1].StartExecutionTime

    #Milliseconds
    If ($LastCommandRunStats.TotalMilliseconds -lt 1000) 
        {([math]::Round($LastCommandRunStats.TotalMilliseconds,3)),'ms';return}
    #Seconds
    If (($LastCommandRunStats.TotalSeconds -gt 1) -AND ($LastCommandRunStats.TotalSeconds -lt 60)) 
        {([math]::Round($LastCommandRunStats.TotalSeconds,3)),'sec';return}
    #Minutes
    If (($LastCommandRunStats.TotalMinutes -gt 1) -AND ($LastCommandRunStats.TotalMinutes -lt 60)) 
        {($LastCommandRunStats.Minutes),'min',[math]::Round(($LastCommandRunStats.TotalSeconds - ($LastCommandRunStats.Minutes * 60)),2),'sec';return}
    #Hours
    If ($LastCommandRunStats.TotalMilliseconds -gt 1) 
        {"`r`n",'Started at:',(Get-History)[-1].EndExecutionTime,"`r`n",'Ended at:',(Get-History)[-1].StartExecutionTime,"`r`n",([math]::Round($LastCommandRunStats.TotalHours,3)),'hours',"`r`n",($LastCommandRunStats.Hours),'hours',($LastCommandRunStats.Minutes),'min',[math]::Round(($LastCommandRunStats.TotalSeconds - ($LastCommandRunStats.Minutes * 60)),2),'sec';return}
}

Function Prompt {
    $lastResult = Invoke-Expression '$?'
    if (!$lastResult) {Write-Host "Last command exited with error status." -f Red}
    
    #Colors
    $PromptColor_Timer = "Green"
    $PromptColor_Divider = "White"
    $PromptColor_Path = "White"
    $PromptColor_Leaf = "Green" #<--You can change the foregroundcolor here of the directory you are in

    Write-Host -no "PS: "
    Write-Host -no "$(PromptTimer)" -f $PromptColor_Timer
    
    #Get-Location... when you are at the ROOT
    IF (($(Get-Location) | Split-Path).Length -eq 0) {
        Write-Host -no " | "
        Write-Host -no "$(Get-Location)" -f $PromptColor_Leaf #You are a leaf at this point... no directory
        return "> " #have to use return here os else Powershell will attempt to put the default "PS>" at the end of the line
        }
    #Get-Location... when you are 1 level down from ROOT
    IF ((($(Get-Location) | Split-Path).Length -ne 0) -AND (($(Get-Location) | Split-Path) -eq $(Get-Location).Drive.Root)) {
        Write-Host -no " | " -f $PromptColor_Divider
        Write-Host -no "$(Get-Location | Split-Path)" -f $PromptColor_Path
        Write-Host -no "$(Get-Location | Split-Path -Leaf)" -f $PromptColor_Leaf
        return "> " #have to use return here os else Powershell will attempt to put the default "PS>" at the end of the line
        }
    #Get-Location... when you are >1 level down from the ROOT
    IF (($(Get-Location) | Split-Path).Length -ne 0) {

        Write-Host -no " | " -f $PromptColor_Divider
        Write-Host -no "$(Get-Location | Split-Path)\" -f $PromptColor_Path
        Write-Host -no "$(Get-Location | Split-Path -Leaf)" -f $PromptColor_Leaf
        return "> " #have to use return here os else Powershell will attempt to put the default "PS>" at the end of the line
        }
}
