#!/bin/pwsh

$UPDATE_INFO = $(curl https://update.code.visualstudio.com/api/update/darwin/stable/lol) | ConvertFrom-Json
$LATEST_MS_COMMIT = $UPDATE_INFO.version
$LATEST_MS_TAG = $UPDATE_INFO.name

$env:LATEST_MS_COMMIT = $LATEST_MS_COMMIT
$env:LATEST_MS_TAG = $LATEST_MS_TAG

Write-Information "Got the latest MS tag: ${LATEST_MS_TAG}" -InformationAction Continue

# clone latest tag
git clone https://github.com/Microsoft/vscode.git --branch $LATEST_MS_TAG --depth 1

