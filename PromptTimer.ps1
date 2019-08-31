<#
.SYNOPSIS
  Shows you (on your Powershell prompt) the execution time of the last powershell command you ran.
.DESCRIPTION
  Shows you (on your Powershell prompt) the execution time of the last powershell command you ran.
  Once the function finds a suitable format (going from MS up), it returns, so it should have minimal impact on execution times
  
.OUTPUTS
  Outputs the execution time of your last command, and it automaticallly switches between 
  millliseconds, seconds, minutes, hours, etc based on how long the command took to run.
  
  Format changes as the execution time gets longer:
    It will not show you: 1340.043435 ms, it will show you: 1.340 sec
    It will not show you: 90.50 sec, it will show you: 1 min 30 sec
    Also, when the command goes over 1 Hour, it will show you StartExecutionTime and EndExecutionTime, along
      with a decimal representation of the hours, and the breakdown of Hours, Minutes and Seconds
    No plans yet to do anything when it goes over 24 hours.
    
  
  
  Error Handling
    If the command is cancelled, or exits with an error status, it will display a message on the prompt 
    (no matter what length of execution time)

.NOTES
  Version:        1.2
  Author:         Ben Therien (Inventologist)
  Creation Date:  2019/08/31

.EXAMPLE
  Must be put into your Powershell Profile.
  At the powershell prompt, type: notepad $profile
  It may have to CREATE the file, if you don't already use the $profile functionality

  When the notepad file comes up, paste the code below into the profile, save, close and then restart powershell.  All set!
  ENJOY!!
#>

function CommandPromptTimer {
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

function prompt {
    $lastResult = Invoke-Expression '$?'
    if (!$lastResult) {Write-Host "Last command exited with error status." -ForegroundColor Red}
    
    "PS: $(CommandPromptTimer) | $(Get-Location)> "
}


