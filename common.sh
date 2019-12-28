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

# =============================================================================
# General Functions
# =============================================================================

# Gets the latest version number of a project on GitHub/GitLab
# Params:
#   - GitHub/GitLab
#   - Username
#   - Project name
#   - Include Prerelease (Only for GitHub)
# Returns:
#   The latest version number.
get_latest_release_version () {
    file="/tmp/$(uuidgen)"
    status=$(curl -G -H "User-Agent: Kosmos-Builder/2.0.0" -o ${file} -s -w "%{http_code}" https://kosmos-builder.teamatlasnx.com/${1}/${2}/${3}/version --data-urlencode "prerelease=${4}")
    if [[ ${status} = "404" ]]
    then
        echo "Not Found"
    elif [[ ${status} != "200" ]]
    then
        echo "Error"
    else
        response=$(cat ${file})
        echo $response
    fi
    rm -f "${file}"
}

# Gets the latest release download URL of a project on GitHub/GitLab
# Params:
#   - GitHub/GitLab
#   - Username
#   - Project name
#   - RegExp Pattern
#   - Group Number (Only needed for GitLab)
#   - Include Prerelease (Only for GitHub)
# Returns:
#   The latest release download URL.
get_latest_release_download_url () {
    file="/tmp/$(uuidgen)"
    status=$(curl -G -H "User-Agent: Kosmos-Builder/2.0.0" -o ${file} -s -w "%{http_code}" https://kosmos-builder.teamatlasnx.com/${1}/${2}/${3}/release --data-urlencode "pattern=${4}" --data-urlencode match="${5}"  --data-urlencode "prerelease=${6}")
    if [[ ${status} = "404" ]]
    then
        echo "Not Found"
    elif [[ ${status} != "200" ]]
    then
        echo "Error"
    else
        response=$(cat ${file})
        echo $response
    fi
    rm -f "${file}"
}

# Downloads a file from URL.
# Params:
#   - URL
# Returns:
#   The file path.
get_file () {
    file="/tmp/$(uuidgen)"
    status=$(curl -L -H "User-Agent: Kosmos-Builder/2.0.0" -o ${file} -s -w "%{http_code}" ${1})
    if [[ ${status} != "200" ]]
    then
        echo "Error"
        rm -f "${file}"
    else
        echo ${file}
    fi
}

# Find path matching a pattern
# Params:
#   - The pattern
# Returns:
#   The first file found.
glob () {
    files=( ${1} )
    echo ${files[0]}
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
