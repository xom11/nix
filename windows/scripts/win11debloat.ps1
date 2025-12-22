& ([scriptblock]::Create((irm "https://debloat.raphi.re/"))) `
    -Silent `
    -RunDefaults `
    -RemoveApps `
    -RemoveGaming `
    -DisableTelemetry `
    -DisableBing `
    -DisableSuggestions `
    -DisableLockscreenTips
