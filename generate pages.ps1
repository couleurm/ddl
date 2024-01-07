#$env:DONT_CLEANUP=1
Set-Location $PSScriptRoot
$ErrorActionPreference = 'Stop'

'DDL_repos', # where the repos are gonna be downloaded and unzipped
'ddl'  | # contains all the html files this script generates
ForEach-Object {
    if (-not(Test-Path ./$_)) {
        mkdir ./$_
    }
}

function Generate-RedirectPage ($filename, $jsonUrl, $overrideUrl = '') {

    $buffer = Get-Content ./template.html

    if (-not(Test-Path ./$filename)) {
        mkdir ./$filename | Out-Null
    }



    $buffer -replace 'REPLACE_WITH_FILENAME', $filename    `
        -replace 'REPLACE_WITH_URL', $jsonUrl     `
        -replace 'REPLACE_WITH_OVERRIDEURL', $overrideUrl `
    | Set-Content ./$filename/index.html
}

$filemaps = @(
    @{
        filename    = "obs-studio-installer"
        jsonUrl     = "https://raw.githubusercontent.com/ScoopInstaller/Extras/master/bucket/obs-studio.json"
        overrideUrl = "https://cdn-fastly.obsproject.com/downloads/OBS-Studio-{0}-Full-Installer-x64.exe"
    },
    @{
        filename    = "telegram-installer"
        jsonUrl     = "https://raw.githubusercontent.com/ScoopInstaller/Extras/master/bucket/telegram.json"
        overrideUrl = "https://github.com/telegramdesktop/tdesktop/releases/download/v{0}/tsetup-x64.{0}.exe"
    }
    @{
        filename    = "discord-installer"
        jsonUrl     = "https://raw.githubusercontent.com/ScoopInstaller/Extras/master/bucket/telegram.json" #it doesnt matter lol
        overrideUrl = "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86"
    }
)

foreach ($program in $filemaps) {

    Generate-RedirectPage @program

}

# all manifests from these are automatically generated
@(
    @{owner = "couleur-tweak-tips"; name = "utils";              branch = "main";   folder = 'bucket' }
    @{owner = "ScoopInstaller";     name = "Extras";             branch = "master"; folder = 'bucket' }
    @{owner = "ScoopInstaller";     name = "Main";               branch = "master"; folder = 'bucket' }
    @{owner = "ScoopInstaller";     name = "Versions";           branch = "master"; folder = 'bucket' }
    @{owner = "kodybrown";          name = "scoop-nirsoft";      branch = "master"; folder = 'bucket' }
    @{owner = "niheaven";           name = "scoop-sysinternals"; branch = "main";   folder = 'bucket' }
    @{owner = "ScoopInstaller";     name = "PHP";                branch = "master"; folder = 'bucket' }
    @{owner = "matthewjberger";     name = "scoop-nerd-fonts";   branch = "master"; folder = 'bucket' }
    @{owner = "ScoopInstaller";     name = "Nonportable";        branch = "master"; folder = 'bucket' }
    @{owner = "ScoopInstaller";     name = "Java";               branch = "master"; folder = 'bucket' }
    @{owner = "Calinou";            name = "scoop-games";        branch = "master"; folder = 'bucket' }
) | ForEach-Object {
    $owner, $name, $branch, $folder = $_.owner, $_.name, $_.branch, $_.folder

    $Response = Invoke-RestMethod "https://api.github.com/repos/$owner/$name/git/trees/$branch`?recursive=1"
    $Manifests = $Response.tree.path | Where-Object { $_ -Like "$folder/*.json" }
    $Manifests = ($Manifests).Replace('bucket/', '').Replace('.json', '')

    Write-Warning "Generating redirects for $owner/$name"

    foreach ($filename in $Manifests) {

        $jsonUrl = "https://raw.githubusercontent.com/$owner/$name/$branch/bucket/$filename.json"

        Generate-RedirectPage -filename $filename -jsonUrl $jsonUrl
    }
}

if (!$env:DONT_CLEANUP) {
    Write-Warning "Removing temporary repositories"
    if (!$isLinux) {
        [Console]::Beep(3000, 1000)
        [Console]::Beep(500, 1000)
        [Console]::Beep(2500, 1000)
        Start-Sleep 5
        Remove-Item ./DDL_repos/ -Force -Confirm -Recurse
        Remove-Item ./template.html
    }
    else {
        rm DDL_repos -rf
        rm template.html
    }
    
}

(Get-ChildItem -Directory).BaseName | Set-Content ./list.txt