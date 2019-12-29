#!/bin/bash
#
# Kosmos
# Copyright (C) 2019 Nichole Mattera
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

func_res_version=""
func_res_file=""

# Downloads the latest release to a temp file.
# Params:
#   - GitHub/GitLab
#   - Username
#   - Project name
#   - RegExp Pattern
#   - Group Number (Only needed for GitLab)
#   - Include Prerelease (Only for GitHub)
# Returns:
#   Check func_res_version, and func_res_file.
download() {
    func_res_version=""
    func_res_file=""

    # Get version number.
    version=$(./common.sh get_latest_release_version "${1}" "${2}" "${3}" "${6}")
    if [[ $version = "Not Found" || $version = "Error" ]]
    then
        return 1
    fi

    # Get release URL.
    url=$(./common.sh get_latest_release_download_url "${1}" "${2}" "${3}" "${4}" "${5}" "${6}")
    if [[ $url = "Not Found" || $url = "Error" ]]
    then
        return 2
    fi

    # Download the release.
    if [[ $1 = "gitlab" && $url =~ ^\/.* ]]
    then
        url="https://gitlab.com/${2}/${3}${url}"
    fi
    
    file=$(./common.sh get_file "${url}")
    if [[ $file = "Error" ]]
    then
        return 3
    fi

    func_res_version="${version}"
    func_res_file="${file}"

    return 0
}

# Print out the error
# Params:
#   - Error code
#   - Username
#   - Project name
#   - RegExp Pattern
print_error() {
    if [[ $1 -eq 1 ]]
    then
        echo "[Error] Unable to get ${2}/${3} version number."
    elif [[ $1 -eq 2 ]]
    then
        echo "[Error] Unable to get release URL for ${2}/${3}. (${4})"
    else
         echo "[Error] Unable to download ${2}/${3}."
    fi
}

# Downloads the latest Atmosphere release.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_atmosphere () {
    mkdir -p "${1}"

    download "github" "Atmosphere-NX" "Atmosphere" ".*atmosphere-.*\.zip" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "Atmosphere-NX" "Atmosphere" ".*atmosphere-.*\.zip"
        return 1
    fi
    atmosphere_version="${func_res_version}"
    atmosphere_file="${func_res_file}"

    download "github" "Atmosphere-NX" "Atmosphere" ".*fusee-primary.bin" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "Atmosphere-NX" "Atmosphere" ".*fusee-primary.bin"
        return 1
    fi
    fusee_file="${func_res_file}"

    # Assemble everything
    unzip -qq -o "${atmosphere_file}" -d "${1}"
    rm -f "${atmosphere_file}"
    rm -f "${1}/switch/reboot_to_payload.nro"
    rm -f "${1}/atmosphere/reboot_payload.bin"
    mkdir -p "${1}/bootloader/payloads"
    mv "${fusee_file}" "${1}/bootloader/payloads/fusee-primary.bin"
    cp "./Modules/atmosphere/system_settings.ini" "${1}/atmosphere/config/system_settings.ini"

    # Return the version number
    echo "${atmosphere_version}"
}

# Downloads the latest Hekate release.
# Params:
#   - Directory to extract to
#   - The Kosmos version number
# Returns:
#   The version number.
download_hekate () {
    mkdir -p "${1}"
    
    download "github" "CTCaer" "hekate" ".*hekate_ctcaer_.*\.zip" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "CTCaer" "hekate" ".*hekate_ctcaer_.*\.zip"
        return 1
    fi
    hekate_version="${func_res_version}"
    hekate_file="${func_res_file}"

    # Assemble everything
    unzip -qq -o "${hekate_file}" -d "${1}"
    rm -f "${hekate_file}"
    payload=$(./common.sh glob "${1}/hekate_ctcaer_*.bin")
    cp "${payload}" "${1}/bootloader/update.bin"
    cp "./Modules/hekate/bootlogo.bmp" "${1}/bootloader/bootlogo.bmp"
    cp "${payload}" "${1}/atmosphere/reboot_payload.bin"
    sed "s/KOSMOS_VERSION/${2}/g" "./Modules/hekate/hekate_ipl.ini" >> "${1}/bootloader/hekate_ipl.ini"

    # Return the version number
    echo "${hekate_version}"
}

# Downloads the latest App Store release.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_appstore () {
    mkdir -p "${1}"

    download "gitlab" "4TU" "hb-appstore" "\((.*\.nro\.zip)\)" "1" "false"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "4TU" "hb-appstore" "\((.*\.nro\.zip)\)"
        return 1
    fi
    appstore_version="${func_res_version}"
    appstore_file="${func_res_file}"
    
    # Assemble everything
    mkdir -p "${1}/switch/appstore"
    unzip -qq -o "${appstore_file}" -d "${1}/switch/appstore"
    rm -f "${appstore_file}"

    # Return the version number
    echo "${appstore_version}"
}

# Downloads the latest Edizon release.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_edizon () {
    mkdir -p ${1}

    download "github" "WerWolv" "EdiZon" ".*SD\.zip" "0" "true"
    if [[ $? -eq 2 ]]
    then
        download "github" "WerWolv" "EdiZon" ".*EdiZon\.nro" "0" "true"
        if [[ $? -gt 0 ]]
        then
        print_error "${?}" "WerWolv" "EdiZon" ".*EdiZon\.nro"
            return 1
        fi
        edizon_version="${func_res_version}"
        edizon_file="${func_res_file}"
        
        # Assemble everything
        mkdir -p "${1}/switch/EdiZon"
        mv "${edizon_file}" "${1}/switch/EdiZon/EdiZon.nro"  
    elif [[ $? -gt 0 ]]
    then
        print_error "${?}" "WerWolv" "EdiZon" ".*SD\.zip"
        return 1
    else
        edizon_version="${func_res_version}"
        edizon_file="${func_res_file}"

        # Assemble everything
        unzip -qq -o "${edizon_file}" -d "${1}"
        rm -f "${edizon_file}"
    fi

    # Return the version number
    echo "${edizon_version}"
}

# Downloads the latest Emuiibo release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_emuiibo () {
    mkdir -p ${1}

    download "github" "XorTroll" "emuiibo" ".*emuiibo\.zip" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "XorTroll" "emuiibo" ".*emuiibo\.zip"
        return 1
    fi
    emuiibo_version="${func_res_version}"
    emuiibo_file="${func_res_file}"

    # Assemble everything
    unzip -qq -o "${emuiibo_file}" -d "${1}"
    rm -f "${emuiibo_file}"
    mkdir -p "${1}/atmosphere/contents"
    mv "${1}/titles/0100000000000352" "${1}/atmosphere/contents/0100000000000352"
    rm -f "${1}/atmosphere/contents/0100000000000352/flags/boot2.flag"
    rm -rf "${1}/titles"

    # Return the version number
    echo "${emuiibo_version}"
}

# Downloads the latest Goldleaf release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_goldleaf () {
    mkdir -p ${1}

    download "github" "XorTroll" "Goldleaf" ".*Goldleaf\.nro" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "XorTroll" "Goldleaf" ".*Goldleaf\.nro"
        return 1
    fi
    goldleaf_version="${func_res_version}"
    goldleaf_file="${func_res_file}"

    # Assemble everything
    mkdir -p "${1}/switch/Goldleaf"
    mv ${goldleaf_file} "${1}/switch/Goldleaf/Goldleaf.nro"

    # Return the version number
    echo "${goldleaf_version}"
}

# Downloads the latest Kosmos Toolbox release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_kosmos_toolbox () {
    mkdir -p ${1}

    download "github" "AtlasNX" "Kosmos-Toolbox" ".*KosmosToolbox\.nro" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "AtlasNX" "Kosmos-Toolbox" ".*KosmosToolbox\.nro"
        return 1
    fi
    toolbox_version="${func_res_version}"
    toolbox_file="${func_res_file}"
    
    # Assemble everything
    mkdir -p "${1}/switch/KosmosToolbox"
    mv "${toolbox_file}" "${1}/switch/KosmosToolbox/KosmosToolbox.nro"
    cp "./Modules/kosmos-toolbox/config.json" "${1}/switch/KosmosToolbox/config.json"

    # Return the version number
    echo "${toolbox_version}"
}

# Downloads the latest Kosmos Updater release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_kosmos_updater () {
    mkdir -p ${1}

    download "github" "AtlasNX" "Kosmos-Updater" ".*KosmosUpdater\.nro" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "AtlasNX" "Kosmos-Updater" ".*KosmosUpdater\.nro"
        return 1
    fi
    updater_version="${func_res_version}"
    updater_file="${func_res_file}"
    
    # Assemble everything
    mkdir -p "${1}/switch/KosmosUpdater"
    mv ${updater_file} "${1}/switch/KosmosUpdater/KosmosUpdater.nro"
    sed "s/KOSMOS_VERSION/${2}/g" "./Modules/kosmos-updater/internal.db" >> "${1}/switch/KosmosUpdater/internal.db"

    # Return the version number
    echo "${updater_version}"
}

# Downloads the latest ldn_mitm release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_ldn_mitm () {
    mkdir -p ${1}

    download "github" "spacemeowx2" "ldn_mitm" ".*ldn_mitm_.*\.zip" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "spacemeowx2" "ldn_mitm" ".*ldn_mitm_.*\.zip"
        return 1
    fi
    ldnmitm_version="${func_res_version}"
    ldnmitm_file="${func_res_file}"
    
    # Assemble everything
    unzip -qq -o "${ldnmitm_file}" -d "${1}"
    rm -f "${ldnmitm_file}"
    rm -f "${1}/atmosphere/contents/4200000000000010/flags/boot2.flag"

    # Return the version number
    echo "${ldnmitm_version}"
}

# Downloads the latest Lockpick release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_lockpick () {
    mkdir -p ${1}

    download "github" "shchmue" "Lockpick" ".*Lockpick\.nro" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "shchmue" "Lockpick" ".*Lockpick\.nro"
        return 1
    fi
    lockpick_version="${func_res_version}"
    lockpick_file="${func_res_file}"
    
    # Assemble everything
    mkdir -p "${1}/switch/Lockpick"
    mv ${lockpick_file} "${1}/switch/Lockpick/Lockpick.nro"

    # Return the version number
    echo "${lockpick_version}"
}

# Downloads the latest Lockpick RCM release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_lockpick_rcm () {
    mkdir -p ${1}

    download "github" "shchmue" "Lockpick_RCM" ".*Lockpick_RCM\.bin" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "shchmue" "Lockpick_RCM" ".*Lockpick_RCM\.bin"
        return 1
    fi
    lockpickrcm_version="${func_res_version}"
    lockpickrcm_file="${func_res_file}"
    
    # Assemble everything
    mkdir -p "${1}/bootloader/payloads"
    mv ${lockpickrcm_file} "${1}/bootloader/payloads/Lockpick_RCM.bin"

    # Return the version number
    echo "${lockpickrcm_version}"
}

# Downloads the latest NXDumpTool release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_nxdumptool () {
    mkdir -p ${1}

    download "github" "DarkMatterCore" "nxdumptool" ".*nxdumptool\.nro" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "DarkMatterCore" "nxdumptool" ".*nxdumptool\.nro"
        return 1
    fi
    nxdumptool_version="${func_res_version}"
    nxdumptool_file="${func_res_file}"
    
    # Assemble everything
    mkdir -p "${1}/switch/NXDumpTool"
    mv ${nxdumptool_file} "${1}/switch/NXDumpTool/NXDumpTool.nro"

    # Return the version number
    echo "${nxdumptool_version}"
}

# Downloads the latest sys_clk release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_sys_clk () {
    mkdir -p ${1}

    download "github" "retronx-team" "sys-clk" ".*sys-clk-.*\.zip" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "retronx-team" "sys-clk" ".*sys-clk-.*\.zip"
        return 1
    fi
    sysclk_version="${func_res_version}"
    sysclk_file="${func_res_file}"
    
    # Assemble everything
    unzip -qq -o "${sysclk_file}" -d "${1}"
    rm -f "${sysclk_file}"
    mv "${1}/atmosphere/titles/00FF0000636C6BFF" "${1}/atmosphere/contents/00FF0000636C6BFF"
    rm -rf "${1}/atmosphere/titles"
    rm -f "${1}/atmosphere/contents/00FF0000636C6BFF/flags/boot2.flag"
    rm -f "${1}/README.md"

    # Return the version number
    echo "${sysclk_version}"
}

# Downloads the latest sys-ftpd-light release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_sys_ftpd_light () {
    mkdir -p ${1}

    download "github" "cathery" "sys-ftpd-light" ".*sys-ftpd-light\.zip" "0" "true"
    if [[ $? -gt 0 ]]
    then
        print_error "${?}" "cathery" "sys-ftpd-light" ".*sys-ftpd-light\.zip"
        return 1
    fi
    sysftpdlight_version="${func_res_version}"
    sysftpdlight_file="${func_res_file}"
    
    # Assemble everything
    unzip -qq -o "${sysftpdlight_file}" -d "${1}"
    rm -f "${sysftpdlight_file}"
    rm -f "${1}/atmosphere/contents/420000000000000E/flags/boot2.flag"

    # Return the version number
    echo "${sysftpdlight_version}"
}

remove_configs () {
    # Atmosphere
    rm -f "${1}/atmosphere/config/BCT.ini"
    rm -f "${1}/atmosphere/config/system_settings.ini"

    # System Modules
    rm -f "${1}/config/hid_mitm/config.ini"
    rm -f "${1}/config/sys-clk/config.ini"
    rm -f "${1}/config/sys-ftpd/config.ini"

    # Apps
    rm -f "${1}/switch/KosmosToolbox/config.json"
    rm -f "${1}/switch/KosmosUpdater/settings.cfg"
}

# =============================================================================
# Main Script
# =============================================================================

if [[ $# -le 1 ]]
then
    echo "This is not meant to be called by end users and is used by the kosmos.sh and sdsetup.sh scripts."
    exit 1
fi

# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null
then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name" >&2
  exit 1
fi
