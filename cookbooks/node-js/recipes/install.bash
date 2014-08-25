#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Clean Up

    rm -f -r "${nodejsInstallFolder}" '/usr/local/bin/node' '/usr/local/bin/npm'
    mkdir -p "${nodejsInstallFolder}"

    # Install

    if [[ "${nodejsVersion}" = 'latest' ]]
    then
        nodejsVersion="$(getLatestVersionNumber)"
        local url="http://nodejs.org/dist/latest/node-v${nodejsVersion}-linux-x64.tar.gz"
    else
        local url="http://nodejs.org/dist/v${nodejsVersion}/node-v${nodejsVersion}-linux-x64.tar.gz"
    fi

    if [[ "$(existURL "${url}")" = 'true' ]]
    then
        unzipRemoteFile "${url}" "${nodejsInstallFolder}"
        chown -R "$(whoami)":"$(whoami)" "${nodejsInstallFolder}"
        symlinkLocalBin "${nodejsInstallFolder}/bin"

        # Config Profile

        local profileConfigData=('__INSTALL_FOLDER__' "${nodejsInstallFolder}")

        createFileFromTemplate "${appPath}/../templates/default/node-js.sh.profile" '/etc/profile.d/node-js.sh' "${profileConfigData[@]}"

        info "\nNode Version: $(node --version)"
        info "NPM Version : $(npm --version)"
    else
        fatal "\nFATAL: version '${nodejsVersion}' not found!"
    fi
}

function getLatestVersionNumber()
{
    local versionPattern='[[:digit:]]{1,2}\.[[:digit:]]{1,2}\.[[:digit:]]{1,3}'
    local shaSum256="$(getRemoteFileContent 'http://nodejs.org/dist/latest/SHASUMS256.txt.asc')"

    echo "${shaSum256}" | grep -E -o "node-v${versionPattern}\.tar\.gz" | grep -E -o "${versionPattern}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NODE-JS'

    installDependencies
    install
    installCleanUp
}

main "${@}"