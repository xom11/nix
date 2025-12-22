& [scriptblock]::Create((Invoke-RestMethod "https://debloat.raphi.re/")) `
    -Silent `
    -RunDefaults `
    -RemoveApps `
    -RemoveGaming `
    -DisableTelemetry `
    -DisableBing `
    -DisableSuggestions `
    -DisableLockscreenTips
