#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

base_path="https://github.com/gohugoio/hugo/releases/download/"
#new_version="v0.106.0"
new_version=$(curl --silent 'https://api.github.com/repos/gohugoio/hugo/releases/latest' | jq -r .tag_name)
hugo_extended="/hugo_extended_"
hugo_version=${new_version:1}
hugo_arch="_Linux-amd64.tar.gz"
destination="/usr/local/bin/hugo"

printf %b "................................ \n"
printf %b "Download and install Hugo binary \n"
printf %b "................................ \n"
printf %b "New version is: ${new_version} \n"
printf %b "Is it correct (y/n)?"
read -r answer
if [ "$answer" != "${answer#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.
    printf %b "OK. \n"
else
    printf %b "Type the correct version number, please. (for example: v0.91.0): "
    read -r corrected_version
    printf %b "New version is: ${corrected_version} \n"
    printf %b "Is it correct (y/n)?"
    read -r answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.
        printf %b "OK. \n"
        new_version=${corrected_version}
        hugo_version=${new_version:1}
    else
        printf %b "Sorry. We have to exit. \n"
        printf %b "................................ \n"
        exit 1
    fi
fi

mkdir -p ~/Downloads/Hugo
cd ~/Downloads/Hugo
mkdir -p "${new_version:1}"
cd "${new_version:1}"

if [[ -e "hugo_extended_${hugo_version}${hugo_arch}" ]]; then
    printf %b "OK. We already have that version of Hugo archive. \n"
else
    printf %b "Downloading... \n"
    wget "${base_path}${new_version}${hugo_extended}${hugo_version}${hugo_arch}"
fi

if [[ -e hugo ]] && (./hugo version tee /dev/null | grep --quiet --ignore-case "${new_version}"); then
    printf %b "OK. We already have that version of Hugo binary. \n"
else
    printf %b "Extracting... \n"
    tar -xvf "./hugo_extended_${hugo_version}${hugo_arch}"
fi

printf %b "................................ \n"
#printf %b "bla bla bla >>> ${base_path}${new_version}${hugo_extended}${hugo_version}${hugo_arch} <<< \n"
if [ -f "$destination" ]; then
    current_version_string=$(hugo version tee /dev/null | grep -Eo '[0-9]\.[0-9]+\.[0-9]+')
    current_version_number=$(hugo version tee /dev/null | grep -Eo '[0-9]\.[0-9]+\.[0-9]+' | sed 's/\.//g') #$(hugo version tee /dev/null | grep -Eo '[0-9]\.[0-9]+\.[0-9]+')
else
    current_version_string="N/A"
    current_version_number="0"
fi
printf %b "Current version: $current_version_string \n"
installing_version_string=$(./hugo version tee /dev/null | grep -Eo '[0-9]\.[0-9]+\.[0-9]+')
installing_version_number=$(./hugo version tee /dev/null | grep -Eo '[0-9]\.[0-9]+\.[0-9]+' | sed 's/\.//g') #$(./hugo version tee /dev/null | grep -Eo '[0-9]\.[0-9]+\.[0-9]+')
printf %b "Installing version: $installing_version_string \n"

if [ "$current_version_number" -gt "$installing_version_number" ]; then
    printf %b "Current version of Hugo is newer. We will exit. \n"
    printf %b "................................ \n"
    exit 1
elif [ "$current_version_number" -eq "$installing_version_number" ]; then
    printf %b "Installing version is the same. We will exit. \n"
    printf %b "................................ \n"
    exit 1
else
    printf %b "OK. Installing version is newer. \n"
fi

printf %b "................................ \n"
printf %b "We will copy new Hugo binary to /usr/local/bin \n"
printf %b "We need admin privilege. \n"
if sudo cp ./hugo "$destination"; then
    printf %b "OK. That's all. :) \n"
else
    printf %b "Something is wrong. \n"
    printf %b "................................ \n"
    exit 1
fi

printf %b "................................ \n"
exit 0
