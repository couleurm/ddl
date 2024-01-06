#$env:DONT_CLEANUP=1
$ErrorActionPreference = 'Stop'

'repos', # where the repos are gonna be downloaded and unzipped
'ddl'  | # contains all the html files this script generates
ForEach-Object {
    if (-not(Test-Path ./$_)){
        mkdir ./$_
    }
}

function Generate-RedirectPage ($filename, $jsonUrl, $overrideUrl = ''){

    $buffer = Get-Content ./template.html.txt

    if (-not(Test-Path ./$filename)){
        mkdir ./$filename | Out-Null
    }



    $buffer -replace 'REPLACE_WITH_FILENAME',    $filename    `
            -replace 'REPLACE_WITH_URL',         $jsonUrl     `
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
        jsonUrl    = "https://raw.githubusercontent.com/ScoopInstaller/Extras/master/bucket/telegram.json"
        overrideUrl= "https://github.com/telegramdesktop/tdesktop/releases/download/v{0}/tsetup-x64.{0}.exe"
    }
    @{
        filename    = "discord-installer"
        jsonUrl     = "https://raw.githubusercontent.com/ScoopInstaller/Extras/master/bucket/telegram.json" #it doesnt matter lol
        overrideUrl = "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x86"
    }
)

foreach($program in $filemaps){

    Generate-RedirectPage @program

}

# all manifests from these are automatically generated
$repoUrls = @(
    @{owner="couleur-tweak-tips";   name="utils";               branch="main"}
    @{owner="ScoopInstaller";       name="Extras";              branch="master"}
    @{owner="ScoopInstaller";       name="Main";                branch="master"}
    @{owner="ScoopInstaller";       name="Versions";            branch="master"}
    @{owner="kodybrown";            name="scoop-nirsoft";       branch="master"}
    @{owner="niheaven";             name="scoop-sysinternals";  branch="main"}
    @{owner="ScoopInstaller";       name="PHP";                 branch="master"}
    @{owner="matthewjberger";       name="scoop-nerd-fonts";    branch="master"}
    @{owner="ScoopInstaller";       name="Nonportable";         branch="master"}
    @{owner="ScoopInstaller";       name="Java";                branch="master"}
    @{owner="Calinou";              name="scoop-games";         branch="master"}
) | ForEach-Object {
    $owner, $name, $branch = $_.owner, $_.name, $_.branch

    # by default curl is an alias to Invoke-WebRequest.. =(
    $curl = (Get-Command curl -CommandType Application -ErrorAction Stop).Source | Select-Object -First 1


    if (-not(Test-Path "./repos/$name.zip")){

        & $curl "https://codeload.github.com/$owner/$name/zip/refs/heads/$branch" -o "./repos/$name.zip"

        Expand-Archive "./repos/$name.zip" -DestinationPath "./repos/$name"
    }

    $manifestPaths = Resolve-Path ./repos/$name/*/bucket/*.json

    Get-Item $manifestPaths | ForEach-Object {
        $filename = $_.BaseName
        $jsonUrl = "https://raw.githubusercontent.com/$owner/$name/$branch/bucket/$filename.json"

        $buffer = Get-Content ./template.html.txt

        $buffer -replace 'REPLACE_WITH_FILENAME',    $filename `
                -replace 'REPLACE_WITH_URL',         $jsonUrl  `
                -replace 'REPLACE_WITH_OVERRIDEURL', ''        `
        | Set-Content ./ddl/$filename.html

        Generate-RedirectPage -filename $filename -jsonUrl $jsonUrl

    }
}

if (!$env:DONT_CLEANUP){
    Write-Warning "Removing temporary repositories"
    [Console]::Beep(3000,1000)
    [Console]::Beep(3000,1000)
    [Console]::Beep(3000,1000)
    Start-Sleep 5
    Remove-Item ./repos/ -Force -Confirm
}

(Get-ChildItem -Directory).BaseName | Set-Content ./list.txt