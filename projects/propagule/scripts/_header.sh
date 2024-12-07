#!/usr/bin/env bash

set -euo pipefail


BANNER=$(cat <<'EOF'
 █████╗ ██╗   ██╗██╗ ██████╗███████╗███╗   ██╗███╗   ██╗██╗ █████╗
██╔══██╗██║   ██║██║██╔════╝██╔════╝████╗  ██║████╗  ██║██║██╔══██╗
███████║██║   ██║██║██║     █████╗  ██╔██╗ ██║██╔██╗ ██║██║███████║
██╔══██║╚██╗ ██╔╝██║██║     ██╔══╝  ██║╚██╗██║██║╚██╗██║██║██╔══██║
██║  ██║ ╚████╔╝ ██║╚██████╗███████╗██║ ╚████║██║ ╚████║██║██║  ██║
╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝
EOF
)

os=$(uname -ms)
release="https://github.com/awesome-algorand/avicennia"
version="v1.0.0-beta.1"

Red=''
Green=''
Yellow=''
Blue=''
Opaque=''
Bold_White=''
Bold_Green=''
Reset=''

success() {
  echo -e "${Green}$@ ${Reset}"
}

info() {
  echo -e "${Opaque}$@ ${Reset}"
}

warn() {
  echo -e "${Yellow}WARN${Reset}: ${Opaque}$@ ${Reset}"
}

error() {
    echo -e "${Red}ERROR${Reset}:" "${Yellow}" "$@" "${Reset}" >&2
    exit 1
}

if [[ -t 1 ]]; then
    Reset='\033[0m'
    Red='\033[0;31m'
    Green='\033[0;32m'
    Yellow='\033[0;33m'
    Blue='\033[0;34m'
    Bold_Green='\033[1;32m'
    Bold_White='\033[1m'
    Opaque='\033[0;2m'
    echo -e "${Bold_Green}${BANNER} ${Reset}"
    echo -e "OS: ${Bold_White}${os}${Reset} Version: ${Bold_White}${version}${Reset}"
    echo -e "Release: ${Bold_White}${release}${Reset}"
fi
