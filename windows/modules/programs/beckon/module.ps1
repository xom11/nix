@{
    Description = 'Start Menu shortcut names beckon must resolve by exact display name'
    Apply = {
        param($Ctx)

        # beckon resolves a hotkey id against Start Menu *filenames* -- a shortcut's
        # display name is its file stem, and beckon reads no name out of the .lnk
        # body. An exact stem match is its top resolution tier and settles the id
        # from the directory listing alone (~57ms). Anything weaker -- a substring
        # hit, as with 'Notion' against 'https   www.notion.so' -- falls through to
        # the full packaged-app catalog scan on every single keypress (~400ms).
        #
        # Chromium writes the page URL as the shortcut filename when a site is added
        # via "Create shortcut" instead of "Install this site as an app", which is
        # where the mangled names come from. Renaming the .lnk is the whole fix.
        $renames = @(
            @{ From = 'https   www.notion.so.lnk'; To = 'Notion.lnk' }
        )

        $roots = @(
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
            "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
        ) | Where-Object { Test-Path -LiteralPath $_ }

        if (-not $roots) {
            Write-Warn 'no Start Menu directory found'
            return
        }

        foreach ($rename in $renames) {
            $stem = [IO.Path]::GetFileNameWithoutExtension($rename.To)

            $sources = @(
                foreach ($root in $roots) {
                    Get-ChildItem -LiteralPath $root -Recurse -File -Filter $rename.From -ErrorAction SilentlyContinue
                }
            )

            if (-not $sources) {
                # Already renamed, or the PWA was installed properly in the first
                # place. Either way beckon is fine as long as the target exists.
                $existing = @(
                    foreach ($root in $roots) {
                        Get-ChildItem -LiteralPath $root -Recurse -File -Filter $rename.To -ErrorAction SilentlyContinue
                    }
                )
                if ($existing) { Write-Skip "$stem -> already named '$($rename.To)'" }
                else           { Write-Warn "$stem -> neither '$($rename.From)' nor '$($rename.To)' found" }
                continue
            }

            foreach ($source in $sources) {
                $target = Join-Path $source.DirectoryName $rename.To
                if (Test-Path -LiteralPath $target) {
                    # Chromium recreates the URL-named shortcut when the PWA updates.
                    # The correctly named one already exists, so beckon resolves fine;
                    # leave the duplicate alone rather than delete a user's shortcut.
                    Write-Skip "$stem -> '$($rename.To)' already present, leaving duplicate"
                    continue
                }
                try {
                    Rename-Item -LiteralPath $source.FullName -NewName $rename.To -ErrorAction Stop
                    Write-OK "$stem -> renamed '$($rename.From)'"
                } catch {
                    Write-Fail "$stem -> rename failed: $_"
                }
            }
        }
    }
}
