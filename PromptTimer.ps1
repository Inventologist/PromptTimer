<#
.SYNOPSIS
  Shows you (on your Powershell prompt) the run time of the last powershell command you ran.
.DESCRIPTION
  Shows you (on your Powershell prompt) the run time of the last powershell command you ran.
.OUTPUTS
  Outputs the execution time of your last command, and it automaticallly switches between 
  millliseconds, seconds, minutes, hours, etc based on how long the command took to run.
  It will not show you: 1340.043435 ms, it will show you: 1.340 sec
.NOTES
  Version:        1.0
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
    If (($LastCommandRunStats.TotalSeconds -gt 1) -AND ($LastCommandRunStats.TotalSeconds -lt 120)) 
        {([math]::Round($LastCommandRunStats.TotalSeconds,3)),'sec';return}
    #Minutes
    If (($LastCommandRunStats.TotalMinutes -gt 1) -AND ($LastCommandRunStats.TotalMinutes -lt 120)) 
        {([math]::Round($LastCommandRunStats.TotalMinutes,3)),'min';return}
    #Hours
    If (($LastCommandRunStats.TotalHours -gt 1) -AND ($LastCommandRunStats.TotalHours -lt 24)) 
        {([math]::Round($LastCommandRunStats.TotalHours,3)),'hours';return}
    #Days
    If ($LastCommandRunStats.TotalDays -gt 1) 
        {([math]::Round($LastCommandRunStats.TotalDays,3)),'days';return}
}

function prompt {"PS: $(CommandPromptTimer) | $(Get-Location)> "}