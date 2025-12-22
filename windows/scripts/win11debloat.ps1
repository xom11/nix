$ScriptBlock = [scriptblock]::Create((Invoke-RestMethod "https://debloat.raphi.re/"))

& $ScriptBlock `
    -Silent `
    -RunDefaults `
    -RemoveApps `
    -RemoveGaming `
    -DisableTelemetry `
    -DisableBing `
    -DisableSuggestions `
    -DisableLockscreenTips
