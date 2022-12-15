<# 
    .NOTES 
    =========================================================================== 
     Created with: love by hand in Visual Studio Code 1.63.2 
     Created on: 27/12/2021 10:33 AM 
     Created by: Rado van Zwieratko 
     Organization: zwieratko.sk 
     Filename: update-hugo.ps1 
    =========================================================================== 
    .DESCRIPTION 
     Downloading and installing of binary for Hugo static site generator. 
#>

$current_path_at_start = (Get-Item .).FullName
$base_path = "https://github.com/gohugoio/hugo/releases/download/"
#$new_version = "v0.106.0"
$new_version = curly --silent "https://api.github.com/repos/gohugoio/hugo/releases/latest" | jq -r .tag_name
$hugo_extended = "/hugo_extended_"
$hugo_version = $new_version.substring(1)
$hugo_arch = "_Windows-amd64.zip"

Write-Host $base_path$new_version$hugo_extended$hugo_version$hugo_arch

Write-Host "................................"
Write-Host "Download and isntall Hugo binary"
Write-Host "................................"
Write-Host "New version is: "$new_version
$answer = Read-Host "Is it correct (y/n) ?"
if ($answer -eq 'y') {
    Write-Host "OK."
} else {
    $corrected_version = Read-Host "Type the correct version number, please (for example v0.91.2)"
    Write-Host "New version is: "$corrected_version
    $answer = Read-Host "Is it correct (y/n) ?"
    if ($answer -eq 'y') {
        Write-Host "OK."
        $new_version = $corrected_version
        $hugo_version = $new_version.substring(1)
    } else {
        Write-Host "Sorry. We have to exit."
        Write-Host "................................"
        exit 1
    }
}

#Set-Location D:\bin
$local_path = "D:\bin\"
Write-Host $local_path
New-Item -ItemType "directory" -Path $local_path -Name $hugo_version -Force
#Set-Location $hugo_version
$checked_path = $local_path+$hugo_version+"\hugo_extended_"+$hugo_version+$hugo_arch
Write-Host $checked_path
if (Test-Path -Path $checked_path -PathType Leaf) {
    Write-Host "OK." -ForegroundColor DarkGreen -NoNewline
    Write-Host "We already have that version of Hugo archive."
} else {
    Write-Host "Downloading..."
    $url_for_download = $base_path+$new_version+$hugo_extended+$hugo_version+$hugo_arch
    Write-Host $url_for_download
    Invoke-WebRequest $url_for_download -OutFile $checked_path
}

$checked_path_binary = $local_path+$hugo_version+"\hugo.exe"
Write-Host $checked_path_binary
if (Test-Path -Path $checked_path_binary -PathType Leaf) {
    Write-Host "OK." -ForegroundColor DarkGreen -NoNewline
    Write-Host "We already have that version of Hugo binary."
} else {
    Write-Host "Extracting..."
    Expand-Archive -Path $checked_path -DestinationPath ($local_path+$hugo_version)
}

# Copy Hugo binary to final destination
Copy-Item $checked_path_binary -Destination "D:\bin\hugo"

$installed_hugo_version = (hugo version).substring(6,7)
Write-Host "Installed Hugo version: "$installed_hugo_version

Set-Location $current_path_at_start
# https://github.com/gohugoio/hugo/releases/download/v0.91.2/hugo_extended_0.91.2_Windows-64bit.zip
# D:\bin\0.91.0\hugo_extended_0.91.0_Windows-64bit.zip
# D:\bin\0.91.0\hugo_extended_0.91.0_Windows-64bit.zip
