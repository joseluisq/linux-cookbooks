#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    initializeFolder "${PYTHON_INSTALL_FOLDER}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${PYTHON_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${PYTHON_INSTALL_FOLDER}"
    make
    make install
    ln -f -s "${PYTHON_INSTALL_FOLDER}/bin/python3" '/usr/local/bin/python'
    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${PYTHON_INSTALL_FOLDER}")

    createFileFromTemplate "${appFolderPath}/../templates/python.sh.profile" '/etc/profile.d/python.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$(python --version)"
}

function main()
{
    local -r installFolder="${1}"

    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PYTHON'

    # Override Default Config

    if [[ "$(isEmptyString "${installFolder}")" = 'false' ]]
    then
        PYTHON_INSTALL_FOLDER="${installFolder}"
    fi

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"