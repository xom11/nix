function Write-Banner  { param($Msg) Write-Host ("`n=== {0} ===" -f $Msg) -ForegroundColor Cyan }
function Write-Section { param($Msg) Write-Host (">> {0}"   -f $Msg) -ForegroundColor Magenta }
function Write-OK      { param($Msg) Write-Host ("OK    {0}" -f $Msg) -ForegroundColor Green }
function Write-Skip    { param($Msg) Write-Host ("SKIP  {0}" -f $Msg) -ForegroundColor DarkGray }
function Write-Fail    { param($Msg) Write-Host ("FAIL  {0}" -f $Msg) -ForegroundColor Red }
function Write-Warn    { param($Msg) Write-Host ("WARN  {0}" -f $Msg) -ForegroundColor Yellow }
function Write-Info    { param($Msg) Write-Host ("INFO  {0}" -f $Msg) -ForegroundColor Blue }

Export-ModuleMember -Function Write-Banner, Write-Section, Write-OK, Write-Skip, Write-Fail, Write-Warn, Write-Info
