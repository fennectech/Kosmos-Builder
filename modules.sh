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

# Downloads the latest Atmosphere release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_atmosphere () {
    service="github"
    user="Atmosphere-NX"
    project="Atmosphere"

    mkdir -p "${1}"
    
    # Get version number.
    version=$(./common.sh get_latest_release_version "${service}" "${user}" "${project}")
    if [[ $version = "Not Found" || $version = "Error" ]]
    then
        echo "[Error] Unable to get Atmosphere version number."
        return
    fi

    # Get release URLs.
    atmosphere_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" ".*atmosphere-.*\.zip")
    if [[ $atmosphere_url = "Not Found" || $atmosphere_url = "Error" ]]
    then
        echo "[Error] Unable to get release URL for Atmosphere."
        return
    fi

    fusee_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" ".*fusee-primary.bin")
    if [[ $fusee_url = "Not Found" || $fusee_url = "Error" ]]
    then
        echo "[Error] Unable to get release URL for Fusee Primary."
        return
    fi

    # Download the releases.
    atmosphere=$(./common.sh get_file "${atmosphere_url}")
    if [[ $atmosphere = "Error" ]]
    then
        echo "[Error] Unable to download Atmosphere."
        return
    fi

    fusee=$(./common.sh get_file "${fusee_url}")
    if [[ $fusee = "Error" ]]
    then
        echo "[Error] Unable to download Fusee Primary."
        return
    fi

    # Assemble everything
    unzip -qq -o "${atmosphere}" -d "${1}"
    rm -f "${atmosphere}"
    rm -f "${1}/switch/reboot_to_payload.nro"
    rm -f "${1}/atmosphere/reboot_payload.bin"
    mkdir -p "${1}/bootloader/payloads"
    mv "${fusee}" "${1}/bootloader/payloads/fusee-primary.bin"
    cp "./Modules/atmosphere/system_settings.ini" "${1}/atmosphere/config/system_settings.ini"

    # Return the version number
    echo "${version}"
}

# Downloads the latest Hekate release and extracts it.
# Params:
#   - Directory to extract to
#   - The Kosmos version number
# Returns:
#   The version number.
download_hekate () {
    service="github"
    user="CTCaer"
    project="hekate"

    mkdir -p "${1}"
    
    # Get version number.
    version=$(./common.sh get_latest_release_version "${service}" "${user}" "${project}")
    if [[ $version = "Not Found" || $version = "Error" ]]
    then
        echo "[Error] Unable to get Hekate version number."
        return
    fi

    # Get release URLs.
    hekate_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" ".*hekate_ctcaer_.*\.zip")
    if [[ $hekate_url = "Not Found" || $hekate_url = "Error" ]]
    then
        echo "[Error] Unable to get release URL for Hekate."
        return
    fi

    # Download the releases.
    hekate=$(./common.sh get_file "${hekate_url}")
    if [[ $hekate = "Error" ]]
    then
        echo "[Error] Unable to download Hekate."
        return
    fi

    # Assemble everything
    unzip -qq -o "${hekate}" -d "${1}"
    rm -f "${hekate}"
    payload=$(./common.sh glob "${1}/hekate_ctcaer_*.bin")
    cp "${payload}" "${1}/bootloader/update.bin"
    cp "./Modules/hekate/bootlogo.bmp" "${1}/bootloader/bootlogo.bmp"
    cp "${payload}" "${1}/atmosphere/reboot_payload.bin"
    sed "s/KOSMOS_VERSION/${2}/g" "./Modules/hekate/hekate_ipl.ini" >> "${1}/bootloader/hekate_ipl.ini"

    # Return the version number
    echo "${version}"
}

# Downloads the latest App Store release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_appstore () {
    service="gitlab"
    user="4TU"
    project="hb-appstore"

    mkdir -p "${1}"

    # Get version number.
    version=$(./common.sh get_latest_release_version "${service}" "${user}" "${project}")
    if [[ $version = "Not Found" || $version = "Error" ]]
    then
        echo "[Error] Unable to get App Store version number."
        return
    fi

    # Get release URLs.
    appstore_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" "\((.*\.nro\.zip)\)" "1")
    if [[ $appstore_url = "Not Found" || $appstore_url = "Error" ]]
    then
        echo "[Error] Unable to get release URL for App Store."
        return
    fi

    # Download the releases.
    appstore=$(./common.sh get_file "https://gitlab.com/${user}/${project}${appstore_url}")
    if [[ $appstore = "Error" ]]
    then
        echo "[Error] Unable to download App Store."
        return
    fi

    # Assemble everything
    mkdir -p "${1}/switch/appstore"
    unzip -qq -o "${appstore}" -d "${1}/switch/appstore"
    rm -f "${appstore}"

    # Return the version number
    echo "${version}"
}

# Downloads the latest Edizon release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_edizon () {
    service="github"
    user="WerWolv"
    project="EdiZon"

    mkdir -p ${1}

    # Get version number.
    version=$(./common.sh get_latest_release_version "${service}" "${user}" "${project}" "true")
    if [ $version = "Not Found" ] || [ $version = "Error" ]
    then
        echo "[Error] Unable to get Edizon version number."
        return
    fi

    # Get release URLs.
    edizon_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" ".*SD.zip" "0" "true")
    if [[ $edizon_url = "Error" ]]
    then
        echo "[Error] Unable to get release URL for Edizon."
        return
    elif [[ $edizon_url = "Not Found" ]]
    then
        edizon_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" ".*EdiZon.nro" "0" "true")
        if [[ $edizon_url = "Not Found" || $edizon_url = "Error" ]]
        then
            echo "[Error] Unable to get release URL for Edizon."
            return
        fi

        # Download the releases.
        edizon=$(./common.sh get_file "${edizon_url}")
        if [[ $edizon = "Error" ]]
        then
            echo "[Error] Unable to download Edizon."
            return
        fi

        # Assemble everything
        mkdir -p "${1}/switch/EdiZon"
        mv "${edizon}" "${1}/switch/EdiZon/EdiZon.nro"
    else
        # Download the releases.
        edizon=$(./common.sh get_file "${edizon_url}")
        if [[ $edizon = "Error" ]]
        then
            echo "[Error] Unable to download Edizon."
            return
        fi

        # Assemble everything
        unzip -qq -o "${edizon}" -d "${1}"
        rm -f "${edizon}"
    fi

    # Return the version number
    echo "${version}"
}

# Downloads the latest Emuiibo release and extracts it.
# Params:
#   - Directory to extract to
# Returns:
#   The version number.
download_emuiibo () {
    service="github"
    user="XorTroll"
    project="emuiibo"

    mkdir -p ${1}

    # Get version number.
    version=$(./common.sh get_latest_release_version "${service}" "${user}" "${project}" "true")
    if [[ $version = "Not Found" || $version = "Error" ]]
    then
        echo "[Error] Unable to get Emuiibo version number."
        return
    fi

    # Get release URLs.
    emuiibo_url=$(./common.sh get_latest_release_download_url "${service}" "${user}" "${project}" ".*emuiibo.zip" "0" "true")
    if [[ $emuiibo_url = "Not Found" || $emuiibo_url = "Error" ]]
    then
        echo "[Error] Unable to get release URL for Emuiibo."
        return
    fi

    # Download the releases.
    emuiibo=$(./common.sh get_file "${emuiibo_url}")
    if [[ $emuiibo = "Error" ]]
    then
        echo "[Error] Unable to download Emuiibo."
        return
    fi

    # Assemble everything
    unzip -qq -o "${emuiibo}" -d "${1}"
    rm -f "${emuiibo}"
    rm -f "${1}/titles/0100000000000352/flags/boot2.flag"
    mkdir -p "${1}/atmosphere/contents"
    mv "${1}/titles/0100000000000352" "${1}/atmosphere/contents/"
    rm -rf "${1}/titles"

    # Return the version number
    echo "${version}"
}

download_goldleaf () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "XorTroll" "Goldleaf" "1")

    asset=$(./common.sh find_asset "${latest_release}" "*.nro")
    file=$(./common.sh download_file "${asset}")

    mkdir -p "${1}/switch/Goldleaf"
    mv ${file} "${1}/switch/Goldleaf/Goldleaf.nro"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_kosmos_toolbox () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "AtlasNX" "Kosmos-Toolbox" "1")

    asset=$(./common.sh find_asset "${latest_release}" "*.nro")
    file=$(./common.sh download_file "${asset}")

    mkdir -p "${1}/switch/KosmosToolbox"
    mv "${file}" "${1}/switch/KosmosToolbox/KosmosToolbox.nro"
    cp "./Modules/kosmos-toolbox/config.json" "${1}/switch/KosmosToolbox/config.json"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_kosmos_updater () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${3}" "AtlasNX" "Kosmos-Updater" "0")

    asset=$(./common.sh find_asset "${latest_release}" "*.nro")
    file=$(./common.sh download_file "${asset}")

    mkdir -p "${1}/switch/KosmosUpdater"
    mv ${file} "${1}/switch/KosmosUpdater/KosmosUpdater.nro"
    sed "s/KOSMOS_VERSION/${2}/g" "./Modules/kosmos-updater/internal.db" >> "${1}/switch/KosmosUpdater/internal.db"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_ldn_mitm () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "spacemeowx2" "ldn_mitm" "1")

    asset=$(./common.sh find_asset "${latest_release}" "ldn_mitm*" "*.zip")
    file=$(./common.sh download_file "${asset}")

    unzip -qq "${file}" -d "${1}"
    mv "${1}/atmosphere/titles/4200000000000010" "${1}/atmosphere/contents/4200000000000010"
    rm -rf "${1}/atmosphere/titles"
    rm -f "${1}/atmosphere/contents/4200000000000010/flags/boot2.flag"
    rm -f "${file}"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_lockpick () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "shchmue" "Lockpick" "1")

    asset=$(./common.sh find_asset "${latest_release}" "*.nro")
    file=$(./common.sh download_file "${asset}")

    mkdir -p "${1}/switch/Lockpick"
    mv ${file} "${1}/switch/Lockpick/Lockpick.nro"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_lockpick_rcm () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "shchmue" "Lockpick_RCM" "1")

    asset=$(./common.sh find_asset "${latest_release}" "*.bin")
    file=$(./common.sh download_file "${asset}")

    mkdir -p "${1}/bootloader/payloads"
    mv ${file} "${1}/bootloader/payloads/Lockpick_RCM.bin"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_sys_clk () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "retronx-team" "sys-clk" "1")

    asset=$(./common.sh find_asset "${latest_release}" "sys-clk*" "*.zip")
    file=$(./common.sh download_file "${asset}")

    unzip -qq "${file}" -d "${1}"
    mv "${1}/atmosphere/titles/00FF0000636C6BFF" "${1}/atmosphere/contents/00FF0000636C6BFF"
    rm -rf "${1}/atmosphere/titles"
    rm -f "${1}/atmosphere/contents/00FF0000636C6BFF/flags/boot2.flag"
    rm -f "${1}/README.html"
    rm -f "${1}/README.md"
    rm -f "${file}"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_sys_ftpd_light () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "cathery" "sys-ftpd-light" "1")

    asset=$(./common.sh find_asset "${latest_release}" "sys-ftpd-light*" "*.zip")
    file=$(./common.sh download_file "${asset}")

    unzip -qq "${file}" -d "${1}"
    rm -f "${1}/atmosphere/contents/420000000000000E/flags/boot2.flag"
    rm -f "${file}"

    echo $(./common.sh get_version_number "${latest_release}")
}

download_nxdumptool () {
    mkdir -p ${1}
    latest_release=$(./common.sh get_latest_release "${2}" "DarkMatterCore" "nxdumptool" "1")

    asset=$(./common.sh find_asset "${latest_release}" "nxdumptool*" "*.nro")
    file=$(./common.sh download_file "${asset}")

    mkdir -p "${1}/switch/NXDumpTool"
    mv ${file} "${1}/switch/NXDumpTool/NXDumpTool.nro"

    echo $(./common.sh get_version_number "${latest_release}")
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
