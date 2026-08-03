Describe 'windows programs.beckon Start Menu shortcut names' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:ModulePath = Join-Path $RepoRoot 'windows\modules\programs\beckon\module.ps1'
        $script:ModuleText = Get-Content -Raw -LiteralPath $script:ModulePath
        $script:Module = & $script:ModulePath
    }

    It 'exposes the module contract apply.ps1 expects' {
        $script:Module.Apply | Should Not BeNullOrEmpty
        $script:Module.Description | Should Not BeNullOrEmpty
    }

    It 'renames the URL-named Notion PWA shortcut to its display name' {
        # The whole point: 'Notion' must hit beckon's exact-name tier. Matching by
        # substring against 'https   www.notion.so' works but costs the full
        # packaged-app catalog scan on every keypress.
        $script:ModuleText | Should Match "From = 'https   www\.notion\.so\.lnk'"
        $script:ModuleText | Should Match "To = 'Notion\.lnk'"
    }

    It 'covers both per-user and system-wide Start Menu roots' {
        $script:ModuleText | Should Match 'APPDATA\\Microsoft\\Windows\\Start Menu\\Programs'
        $script:ModuleText | Should Match 'ProgramData\\Microsoft\\Windows\\Start Menu\\Programs'
    }

    It 'never deletes a shortcut' {
        # Chromium recreates the URL-named .lnk when the PWA updates. Leaving the
        # duplicate is correct; removing user shortcuts is not this module's job.
        $script:ModuleText | Should Not Match 'Remove-Item'
    }

    It 'is safe to re-run: skips when the target name already exists' {
        $script:ModuleText | Should Match 'Write-Skip'
        $script:ModuleText | Should Match 'Test-Path -LiteralPath \$target'
    }
}
