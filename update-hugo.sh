#!/usr/bin/env sh

set -o errexit
# set -o pipefail
set -o nounset
# set -o xtrace

# Detect if Hugo is installed and which version
if command -v hugo > /dev/null 2>&1 ;then
    installed_hugo_version=$(hugo version | awk -F' ' '{print $2}' | awk -F'-' '{print $1}')
else
    installed_hugo_version=0
fi
# Detect if it is installed wget / curl
if ! command -v wget > /dev/null 2>&1 && ! command -v midori > /dev/null 2>&1 ;then
    printf %b "We need wget or curl, but it is not installed any of them. \n"
    printf %b "We can install it for you. What would you prefer? [w]get or [c]url ? \n"
    read -r answer
    if expr "$answer" : "^[wW]" > /dev/null = 1 ;then
        printf %b "You selected wget. Great, wget is good choice! \n"
        printf %b "Wait just seconds please. \nThe last little things are being fine-tuned. \n"
        sudo apt-get update > /dev/null 2>&1 && sudo apt-get install wget
    elif expr "$answer" : "^[cC]" > /dev/null = 1 ;then
        printf %b "You selected curl. Great, curl is good choice! \n"
        printf %b "Wait just seconds please. \nThe last little things are being fine-tuned. \n"
        sudo apt-get update > /dev/null 2>&1 && sudo apt-get install curl
    else
        printf %b "Sorry. We can not continue without wget / curl. \n"
        printf %b "End. Bye. \n"
        exit 1
    fi
fi
base_path="https://github.com/gohugoio/hugo/releases/download/"
# Detect latest available version og Hugo at GitHub repository
# Format = "v0.106.0"
if command -v wget > /dev/null 2>&1 ;then
    new_version=$(wget --quiet 'https://api.github.com/repos/gohugoio/hugo/releases/latest' --output-document=- | grep tag_name | awk -F'"' '{print $4}')
elif command -v curl > /dev/null 2>&1 ;then
    new_version=$(curl --silent 'https://api.github.com/repos/gohugoio/hugo/releases/latest' | grep 'tag_name' | awk -F'"' '{print $4}')
else
    printf %b "Sorry. We can not reach information about latest version from GitHub. \n"
    printf %b "End. Bye. \n"
    exit 1
fi

#hugo_extended="/hugo_" # "/hugo_extended_"
hugo_version=$(echo "$new_version" | cut -c 2-) # ${new_version:1}
detect_arch=$(uname -m)
case "$detect_arch" in
    'x86_64')
        printf %b "Detected $detect_arch \n"
        hugo_extended="/hugo_extended_" # "/hugo_extended_" or "/hugo_"
        base_arch="amd64"
        ;;
    'arm64')
        printf %b "Detected $detect_arch \n"
        hugo_extended="/hugo_extended_"
        base_arch="arm64"
        ;;
    'armv7l')
        printf %b "Detected $detect_arch \n"
        hugo_extended="/hugo_"
        base_arch="arm"
        ;;
    'i686')
        printf %b "Detected $detect_arch \n"
        printf %b "Sorry, there is no precompilled 32 bit binary. \n"
        printf %b "End. Bye. \n"
        exit 1
        ;;
    *)
        printf %b "Unknown"
        ;;
esac
hugo_arch="_linux-$base_arch.tar.gz" # "_Linux-amd64.tar.gz"
destination="/usr/local/bin/hugo"

printf %b "\n"
printf %b "....................................... \n"
printf %b "Download and install latest Hugo binary \n"
printf %b "....................................... \n"
printf %b "Version of Hugo installed at system is : ${installed_hugo_version} \n"
printf %b "Latest available version at Github  is : ${new_version} \n"

if [ "$installed_hugo_version" = "$new_version" ]; then
    latest=" latest version of"
else
    latest=""
fi

if [ "$installed_hugo_version" = "$new_version" ] ;then
    printf %b "You already have installed$latest Hugo. \n"
    printf %b "Do you want to install other version [y]es or quit ?"
    read -r answer
    if echo "$answer" | grep -v '^[yY]' > /dev/null 2>&1 ;then # ???
    printf %b "End. Bye. \n"
    exit 0
    else
        answer="n"
        while expr "$answer" : "^[nN]" > /dev/null = 1; do
            printf %b "Type the desired Hugo version number, default [$new_version] \n"
            read -r desired_version
            desired_version=${desired_version:-"$new_version"}
            printf %b "Selected version is $desired_version \n"
            if echo "$desired_version" | grep 'v0\.[0-9]\{2,3\}\.[0-9]' > /dev/null 2>&1 ; then # =~ ^v0\.\d{2,3}\.\d
                printf %b "Is it correct (y/n) ?"
                read -r answer
                answer=${answer:-"y"}
            else
                answer="n"
            fi
            if expr "$answer" : "^[yY]" > /dev/null = 1 ;then
                printf %b "OK. \n"
                new_version="$desired_version"
                hugo_version=$(echo "$new_version" | cut -c 2-) # ${new_version:1}
            fi
        done
    fi
fi
printf %b "Do you want to continue installing version $hugo_version (y/n) ?"
read -r answer
answer=${answer:-"y"}
if expr "$answer" : "^[yY]" > /dev/null = 1 ;then
    printf %b "OK. \n"
else
    printf %b "Sorry. We have to exit. \n"
    printf %b "....................................... \n"
    exit 1
fi

target_dir="$HOME/Downloads/Hugo/$hugo_version"
mkdir -p "$target_dir"
cd "$target_dir"
# mkdir -p "${new_version:1}"
# cd "${new_version:1}"

if [ -e ".${hugo_extended}${hugo_version}${hugo_arch}" ]; then
    printf %b "OK. We already have that version of Hugo archive. \n"
else
    printf %b "Downloading... \n"
    if wget -q --show-progress "${base_path}${new_version}${hugo_extended}${hugo_version}${hugo_arch}"; then
        printf %b "OK. \n"
    else
        printf %b "Sorry. Version $hugo_version is not available. \n"
        printf %b "Sorry. We have to exit. \n"
        exit 1
    fi
fi

if [ -e "$target_dir/hugo" ]; then
    printf %b "OK. We already have that version of Hugo binary. \n"
else
    printf %b "Extracting... \n"
    tar -xvf ./*
fi

if [ "$installed_hugo_version" != "$new_version" ]; then
    # printf %b "Copy new Hugo binary to final destination"
    # sudo cp ./hugo /usr/local/bin/
    printf %b "....................................... \n"
    printf %b "We will copy new Hugo binary to /usr/local/bin \n"
    printf %b "We need admin privilege. \n"
    if sudo cp ./hugo "$destination"; then
        printf %b "OK. That's all. :) \n"
    else
        printf %b "Something is wrong. \n"
        printf %b ".................................... \n"
        exit 1
    fi
fi

if command -v hugo > /dev/null 2>&1 ;then
    installed_hugo_version=$(hugo version | awk -F' ' '{print $2}' | awk -F'-' '{print $1}')
else
    installed_hugo_version=0
fi
printf %b "Version of Hugo installed at system is : ${installed_hugo_version} \n"

printf %b "....................................... \n"
exit 0
