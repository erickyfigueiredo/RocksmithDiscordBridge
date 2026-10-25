function Get-SteamLibraryRoots {
    $taskRoots = New-Object 'System.Collections.Generic.List[string]'
    foreach ($taskRegistry in @(
        @{ Path = 'HKCU:\Software\Valve\Steam'; Property = 'SteamPath' },
        @{ Path = 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam'; Property = 'InstallPath' },
        @{ Path = 'HKLM:\SOFTWARE\Valve\Steam'; Property = 'InstallPath' }
    )) {
        $taskItem = Get-ItemProperty -LiteralPath $taskRegistry.Path -ErrorAction SilentlyContinue
        if ($taskItem) {
            $taskValue = $taskItem.PSObject.Properties[$taskRegistry.Property]
            if ($taskValue -and $taskValue.Value) { $taskRoots.Add([string]$taskValue.Value) }
        }
    }
    if (${env:ProgramFiles(x86)}) { $taskRoots.Add((Join-Path ${env:ProgramFiles(x86)} 'Steam')) }
    return @($taskRoots | Select-Object -Unique)
}

function Find-RocksmithDirectory {
    param([string[]]$SteamRoots = (Get-SteamLibraryRoots))
    $taskLibraries = New-Object 'System.Collections.Generic.List[string]'
    foreach ($taskRoot in $SteamRoots) {
        $taskLibraries.Add($taskRoot)
        $taskVdf = Join-Path $taskRoot 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $taskVdf -PathType Leaf) {
            $taskContent = [IO.File]::ReadAllText($taskVdf)
            foreach ($taskMatch in [regex]::Matches($taskContent, '"path"\s+"([^"\r\n]+)"')) {
                $taskLibraries.Add($taskMatch.Groups[1].Value.Replace('\\','\'))
            }
        }
    }
    foreach ($taskLibrary in @($taskLibraries | Select-Object -Unique)) {
        $taskInstallName = 'Rocksmith2014'
        $taskManifest = Join-Path $taskLibrary 'steamapps\appmanifest_221680.acf'
        if (Test-Path -LiteralPath $taskManifest -PathType Leaf) {
            $taskMatch = [regex]::Match([IO.File]::ReadAllText($taskManifest), '"installdir"\s+"([^"\r\n]+)"')
            if ($taskMatch.Success) { $taskInstallName = $taskMatch.Groups[1].Value }
        }
        $taskDirectory = Join-Path (Join-Path $taskLibrary 'steamapps\common') $taskInstallName
        if (Test-Path -LiteralPath (Join-Path $taskDirectory 'Rocksmith2014.exe') -PathType Leaf) {
            return (Resolve-Path -LiteralPath $taskDirectory).Path
        }
    }
    return $null
}
