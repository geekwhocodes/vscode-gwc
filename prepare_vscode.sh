#!/bin/bash

set -e

if [[ "$CI_WINDOWS" == "True" ]]; then
  export npm_config_arch="$BUILDARCH"
  export npm_config_target_arch="$BUILDARCH"
fi

cp -rp src/* vscode/
cd vscode || exit

../update_settings.sh

# apply patches
# patch -u src/vs/platform/update/electron-main/updateService.win32.ts -i ../patches/update-cache-path.patch

# https://classic.yarnpkg.com/en/docs/yarnrc/#toc-child-concurrency
if [[ "$OS_NAME" == "osx" ]]; then
  CHILD_CONCURRENCY=1 yarn --frozen-lockfile --ignore-optional
  npm_config_argv='{"original":["--ignore-optional"]}' yarn postinstall
else
  #CHILD_CONCURRENCY=10 
  yarn --frozen-lockfile
  yarn postinstall
fi

mv product.json product.json.bak

# set fields in product.json
checksumFailMoreInfoUrl='setpath(["checksumFailMoreInfoUrl"]; "https://go.microsoft.com/fwlink/?LinkId=828886")'
tipsAndTricksUrl='setpath(["tipsAndTricksUrl"]; "https://go.microsoft.com/fwlink/?linkid=852118")'
twitterUrl='setpath(["twitterUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533687")'
requestFeatureUrl='setpath(["requestFeatureUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533482")'
documentationUrl='setpath(["documentationUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533484#vscode")'
introductoryVideosUrl='setpath(["introductoryVideosUrl"]; "https://go.microsoft.com/fwlink/?linkid=832146")'
extensionAllowedBadgeProviders='setpath(["extensionAllowedBadgeProviders"]; ["api.bintray.com", "api.travis-ci.com", "api.travis-ci.org", "app.fossa.io", "badge.fury.io", "badge.waffle.io", "badgen.net", "badges.frapsoft.com", "badges.gitter.im", "badges.greenkeeper.io", "cdn.travis-ci.com", "cdn.travis-ci.org", "ci.appveyor.com", "circleci.com", "cla.opensource.microsoft.com", "codacy.com", "codeclimate.com", "codecov.io", "coveralls.io", "david-dm.org", "deepscan.io", "dev.azure.com", "flat.badgen.net", "gemnasium.com", "githost.io", "gitlab.com", "godoc.org", "goreportcard.com", "img.shields.io", "isitmaintained.com", "marketplace.visualstudio.com", "nodesecurity.io", "opencollective.com", "snyk.io", "travis-ci.com", "travis-ci.org", "visualstudio.com", "vsmarketplacebadge.apphb.com", "www.bithound.io", "www.versioneye.com"])'
updateUrl='setpath(["updateUrl"]; "https://gwc-vscode.geekwhocodes.me")'
releaseNotesUrl='setpath(["releaseNotesUrl"]; "https://go.microsoft.com/fwlink/?LinkID=533483#vscode")'
keyboardShortcutsUrlMac='setpath(["keyboardShortcutsUrlMac"]; "https://go.microsoft.com/fwlink/?linkid=832143")'
keyboardShortcutsUrlLinux='setpath(["keyboardShortcutsUrlLinux"]; "https://go.microsoft.com/fwlink/?linkid=832144")'
keyboardShortcutsUrlWin='setpath(["keyboardShortcutsUrlWin"]; "https://go.microsoft.com/fwlink/?linkid=832145")'
quality='setpath(["quality"]; "stable")'
extensionsGallery='setpath(["extensionsGallery"]; {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "itemUrl": "https://marketplace.visualstudio.com/items", "cacheUrl":"https://vscode.blob.core.windows.net/gallery/index"})'
nameShort='setpath(["nameShort"]; "vscode-gwc")'
nameLong='setpath(["nameLong"]; "vscode-gwc")'
linuxIconName='setpath(["linuxIconName"]; "com.visualstudio.code.oss")'
applicationName='setpath(["applicationName"]; "vscode-gwc")'
win32MutexName='setpath(["win32MutexName"]; "vscode-gwc")'
win32DirName='setpath(["win32DirName"]; "vscode-gwc")'
win32NameVersion='setpath(["win32NameVersion"]; "vscode-gwc")'
win32RegValueName='setpath(["win32RegValueName"]; "vscode-gwc")'
win32AppUserModelId='setpath(["win32AppUserModelId"]; "Microsoft.vscode-gwc")'
win32ShellNameShort='setpath(["win32ShellNameShort"]; "vscode-gwc")'
win32x64UserAppId='setpath (["win32x64UserAppId"]; "{{d8bbdfda-35e0-4adf-a82c-bf05849fc2e3}")'
urlProtocol='setpath(["urlProtocol"]; "vscode-gwc")'
extensionAllowedProposedApi='setpath(["extensionAllowedProposedApi"]; getpath(["extensionAllowedProposedApi"]) + ["ms-vsliveshare.vsliveshare", "ms-vscode-remote.remote-ssh"])'
serverDataFolderName='setpath(["serverDataFolderName"]; ".vscode-server-oss")'

product_json_changes="${checksumFailMoreInfoUrl} | ${tipsAndTricksUrl} | ${twitterUrl} | ${requestFeatureUrl} | ${documentationUrl} | ${introductoryVideosUrl} | ${extensionAllowedBadgeProviders} | ${updateUrl} | ${releaseNotesUrl} | ${keyboardShortcutsUrlMac} | ${keyboardShortcutsUrlLinux} | ${keyboardShortcutsUrlWin} | ${quality} | ${extensionsGallery} | ${nameShort} | ${nameLong} | ${linuxIconName} | ${applicationName} | ${win32MutexName} | ${win32DirName} | ${win32NameVersion} | ${win32RegValueName} | ${win32AppUserModelId} | ${win32ShellNameShort} | ${win32x64UserAppId} | ${urlProtocol} | ${extensionAllowedProposedApi} | ${serverDataFolderName}"
cat product.json.bak | jq "${product_json_changes}" > product.json
cat product.json

../undo_telemetry.sh

cd ..
