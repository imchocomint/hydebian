#!/usr/bin/env bash
#|---/ /+------------------+---/ /|#
#|--/ /-| Global functions |--/ /|#
#|-/ /--| Prasanth Rangan  |-/ /--|#
#|/ /---+------------------+/ /---|#

set -e

scrDir="$(dirname "$(realpath "$0")")"
cloneDir="$(dirname "${scrDir}")"
cloneDir="${CLONE_DIR:-${cloneDir}}"
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"
cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}/hyde"
shlList=("zsh" "fish")
cpistDir="${CLONE_DIR:-${cloneDir}}/Scripts/cpkg"
export cloneDir
export confDir
export cacheDir
export shlList
export cpistDir

pkg_installed() {
    local PkgIn=$1
    dpkg -s "$PkgIn" &>/dev/null
    return $?
}

chk_list() {
    vrType="$1"
    local inList=("${@:2}")
    for pkg in "${inList[@]}"; do
        if pkg_installed "${pkg}"; then
            printf -v "${vrType}" "%s" "${pkg}"
            export "${vrType}"
            return 0
        fi
    done
    return 1
}

pkg_available() {
    local PkgIn=$1
    apt-cache show "$PkgIn" &>/dev/null
    return $?
}

nvidia_detect() {
    readarray -t dGPU < <(lspci -k | grep -E "(VGA|3D)" | awk -F ': ' '{print $NF}')
    if [ "${1}" == "--verbose" ]; then
        for indx in "${!dGPU[@]}"; do
            echo -e "\033[0;32m[gpu$indx]\033[0m detected :: ${dGPU[indx]}"
        done
        return 0
    fi
    if [ "${1}" == "--drivers" ]; then
        # This part needs to be adapted for Debian. Debian doesn't have a simple way to find the driver package name from the device code.
        # This is a placeholder and may require manual input. We'll add the common nvidia packages instead.
        echo "nvidia-driver-470"
        echo "nvidia-driver-525"
        echo "nvidia-driver-535"
        echo "nvidia-driver-550"
        return 0
    fi
    if grep -iq nvidia <<<"${dGPU[@]}"; then
        return 0
    else
        return 1
    fi
}

prompt_timer() {
    set +e
    unset PROMPT_INPUT
    local timsec=$1
    local msg=$2
    while [[ ${timsec} -ge 0 ]]; do
        echo -ne "\r :: ${msg} (${timsec}s) : "
        read -rt 1 -n 1 PROMPT_INPUT && break
        ((timsec--))
    done
    export PROMPT_INPUT
    echo ""
    set -e
}

print_log() {
    local executable="${0##*/}"
    local logFile="${cacheDir}/logs/${HYDE_LOG}/${executable}"
    mkdir -p "$(dirname "${logFile}")"
    local section=${log_section:-}
    {
        [ -n "${section}" ] && echo -ne "\e[32m[$section] \e[0m"
        while (("$#")); do
            case "$1" in
            -r | +r)
                echo -ne "\e[31m$2\e[0m"
                shift 2
                ;;
            -g | +g)
                echo -ne "\e[32m$2\e[0m"
                shift 2
                ;;
            -y | +y)
                echo -ne "\e[33m$2\e[0m"
                shift 2
                ;;
            -b | +b)
                echo -ne "\e[34m$2\e[0m"
                shift 2
                ;;
            -m | +m)
                echo -ne "\e[35m$2\e[0m"
                shift 2
                ;;
            -c | +c)
                echo -ne "\e[36m$2\e[0m"
                shift 2
                ;;
            -wt | +w)
                echo -ne "\e[37m$2\e[0m"
                shift 2
                ;;
            -n | +n)
                echo -ne "\e[96m$2\e[0m"
                shift 2
                ;;
            -stat)
                echo -ne "\e[30;46m $2 \e[0m :: "
                shift 2
                ;;
            -crit)
                echo -ne "\e[97;41m $2 \e[0m :: "
                shift 2
                ;;
            -warn)
                echo -ne "WARNING :: \e[30;43m $2 \e[0m :: "
                shift 2
                ;;
            +)
                echo -ne "\e[38;5;$2m$3\e[0m"
                shift 3
                ;;
            -sec)
                echo -ne "\e[32m[$2] \e[0m"
                shift 2
                ;;
            -err)
                echo -ne "ERROR :: \e[4;31m$2 \e[0m"
                shift 2
                ;;
            *)
                echo -ne "$1"
                shift
                ;;
            esac
        done
        echo ""
    } | if [ -n "${HYDE_LOG}" ]; then
        tee >(sed 's/\x1b\[[0-9;]*m//g' >>"${logFile}")
    else
        cat
    fi
}