#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${goserverJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${goserverJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${goserverServerInstallFolder}"

    # Install

    addUser "${goserverUserName}" "${goserverGroupName}" 'true' 'false' 'true'
    unzipRemoteFile "${goserverServerDownloadURL}" "${goserverServerInstallFolder}"

    local unzipFolderName="$(ls -d ${goserverServerInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'true' || "$(echo "${unzipFolderName}" | wc -l)" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolderName}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolderName}' empty"
    fi

    mv ${unzipFolderName}* "${goserverServerInstallFolder}"
    chown -R "${goserverUserName}:${goserverGroupName}" "${goserverServerInstallFolder}"
    rm -f -r "${unzipFolderName}"
}

function configUpstart()
{
    local upstartConfigData=(
        '__SERVER_INSTALL_FOLDER__' "${goserverServerInstallFolder}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${goserverUserName}")"
        '__USER_NAME__' "${goserverUserName}"
        '__GROUP_NAME__' "${goserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/go-server.conf.upstart" "/etc/init/${goserverServerServiceName}.conf" "${upstartConfigData[@]}"
}

function startServer()
{
    start "${goserverServerServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-SERVER (SERVER)'

    checkRequirePort '8153' '8154'

    installDependencies
    install
    configUpstart
    startServer
    installCleanUp

    displayOpenPorts
}

main "${@}"