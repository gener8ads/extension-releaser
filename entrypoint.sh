#!/bin/sh

set -e

mkdir release

unzip -d release release.zip

jq ". += {\"update_url\": \"$EXTENSION_UPDATE_URL\"}" manifest.json > release/manifest.json

google-chrome-stable --no-sandbox --pack-extension=./release --pack-extension-key=cert.pem