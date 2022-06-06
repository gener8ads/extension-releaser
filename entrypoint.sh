#!/bin/sh

set -e

jq ". += {\"update_url\": \"$EXTENSION_UPDATE_URL\"}" manifest.json > release/manifest.json

google-chrome-stable --pack-extension=./release --pack-extension-key=cert.pem