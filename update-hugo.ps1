<# 
.SYNOPSIS
Hugo downloader

.DESCRIPTION
Downloading and installing of binary for Hugo static site generator.

.NOTES
===========================================================================
Created with: love by hand in Visual Studio Code 1.63.2
Created on: 27/12/2021 10:33 AM
Created by: Rado van Zwieratko
Organization: zwieratko.sk
Filename: update-hugo.ps1
===========================================================================
#>

#PARAMS
[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $increaseDebugVerbosity
)

Write-Host "Wait a seconds, please. Everything is preparing..."
Write-Debug "Debug verbosity is increased! Sorry."

#VARIABLES
$current_path_at_start = (Get-Item .).FullName
# Detect if Hugo is installed and which version
if (Get-Command hugo.exe -ErrorAction SilentlyContinue) {
    $installed_hugo_version = ((((hugo version) -split " ")[1]) -split "-")[0]
}
else {
    $installed_hugo_version = 0
}
$base_path = "https://github.com/gohugoio/hugo/releases/download/"
# Detect latest available version og Hugo at GitHub repository
# Format = "v0.106.0"
$params = @{
    useBasicParsing = $true
    URI             = "https://api.github.com/repos/gohugoio/hugo/releases/latest"
}
$new_version = ((Invoke-WebRequest @params).content | convertfrom-json ).tag_name
$hugo_extended = "/hugo_extended_"
$hugo_version = $new_version.substring(1)
$hugo_arch = "_windows-amd64.zip"

Write-Debug $base_path$new_version$hugo_extended$hugo_version$hugo_arch


Write-Host "......................................."
Write-Host "Download and install latest Hugo binary"
Write-Host "......................................."
Write-Host "Version of Hugo installed at system is :", $installed_hugo_version
Write-Host "Latest available version at Github  is :", $new_version

if ($installed_hugo_version -eq $new_version) {
    Write-Host "We already have installed latest version of Hugo."
    $answer = Read-Host "Do you want to install other version (y/n) ?"
    if ($answer -ne 'y') {
        Write-Host "End."
        Exit
    }
    else {
        $answer = 'n'
        while ($answer -ne 'y') {
            $desired_version = Read-Host "Type the desired version number, please (for example v0.109.0)"
            if ($desired_version -match '^v0\.\d{2,3}\.\d') {
                Write-Host "Selected version is: "$desired_version
                $answer = Read-Host "Is it correct (y/n) ?"
                if (-not $answer) {
                    $answer = 'y'
                }
            }
            else {
                $answer = 'n'
            }
        }
        if ($answer -eq 'y') {
            Write-Host "OK."
            $new_version = $desired_version
            $hugo_version = $new_version.substring(1)
        }
    }
}

$answer = Read-Host "Do you want to continue installing version $hugo_version (y/n) ?"
if (-not $answer) {
    $answer = 'y'
}
if ($answer -eq 'y') {
    Write-Host "OK."
}
else {
    Write-Host "Sorry. We have to exit."
    Write-Host "................................"
    Exit 1
}

#Set-Location D:\bin
$local_path = "D:\bin\"
Write-Debug $local_path


#Set-Location $hugo_version
$checked_path = $local_path + $hugo_version + "\hugo_extended_" + $hugo_version + $hugo_arch
Write-Debug $checked_path

if (Test-Path -Path $checked_path -PathType Leaf) {
    Write-Host "OK." -ForegroundColor DarkGreen -NoNewline
    Write-Host "We already have that version of Hugo archive."
}
else {
    Write-Host "Creating folder..."
    New-Item -ItemType "directory" -Path $local_path -Name $hugo_version -Force
    Write-Host "Downloading..."
    $url_for_download = $base_path + $new_version + $hugo_extended + $hugo_version + $hugo_arch
    Write-Host $url_for_download
    try {
        Invoke-WebRequest $url_for_download -OutFile $checked_path
        Write-Host "OK."
    }
    catch {
        Write-Warning "Sorry. Version $hugo_version is not available."
        Write-Host "End."
        Exit 1
    }
}

$checked_path_binary = $local_path + $hugo_version + "\hugo.exe"
Write-Debug $checked_path_binary

if (Test-Path -Path $checked_path_binary -PathType Leaf) {
    Write-Host "OK." -ForegroundColor DarkGreen -NoNewline
    Write-Host "We already have that version of Hugo binary."
}
else {
    Write-Host "Extracting..."
    Expand-Archive -Path $checked_path -DestinationPath ($local_path + $hugo_version) -Force
}

if ($new_version -ne $installed_hugo_version) {
    # Copy new Hugo binary to final destination
    Copy-Item $checked_path_binary -Destination "D:\bin\hugo.exe"
}

#$installed_hugo_version = (hugo version).substring(6, 7)
$installed_hugo_version = ((((hugo version) -split " ")[1]) -split "-")[0]
Write-Host "Installed Hugo version:", $installed_hugo_version

Set-Location $current_path_at_start

Write-Host "End."
Exit
