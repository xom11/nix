Describe 'windows/lib/Secrets.psm1 ConvertFrom-ShellEnv' {
    BeforeAll {
        $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $LibPath  = Join-Path $RepoRoot 'windows\lib\Secrets.psm1'
        Import-Module $LibPath -Force
    }

    It 'reads export, bare, and single-quoted forms identically' {
        $text = @'
export ALPHA="one"
BRAVO="two"
CHARLIE='three'
'@
        $got = ConvertFrom-ShellEnv -Text $text
        $got.Count       | Should Be 3
        $got['ALPHA']    | Should Be 'one'
        $got['BRAVO']    | Should Be 'two'
        $got['CHARLIE']  | Should Be 'three'
    }

    It 'skips blank lines, comments and junk without throwing' {
        $text = @'

# a comment
export DELTA="four"
this line is not an assignment

export ECHO="five"
'@
        $got = ConvertFrom-ShellEnv -Text $text
        $got.Count    | Should Be 2
        $got['DELTA'] | Should Be 'four'
        $got['ECHO']  | Should Be 'five'
    }

    It 'keeps the value verbatim, including characters a shell would expand' {
        # Không phải khuyến khích -- chỉ chứng minh parser không nội suy.
        $text = 'export FOXTROT="a$b`c"'
        $got = ConvertFrom-ShellEnv -Text $text
        $got['FOXTROT'] | Should Be 'a$b`c'
    }

    It 'preserves inner quotes and only strips the outer pair' {
        $text = 'export GOLF="say ""hi"""'
        $got = ConvertFrom-ShellEnv -Text $text
        $got['GOLF'] | Should Be 'say ""hi""'
    }

    It 'returns an empty dictionary for empty input' {
        $got = ConvertFrom-ShellEnv -Text ''
        $got.Count | Should Be 0
    }

    It 'handles CRLF as well as LF' {
        $text = "export HOTEL=`"six`"`r`nexport INDIA=`"seven`"`r`n"
        $got = ConvertFrom-ShellEnv -Text $text
        $got.Count | Should Be 2
    }
}
