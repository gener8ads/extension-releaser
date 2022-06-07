#!/bin/sh

set -e

main() {
    prepare_creds
    signing_operation
}

prepare_creds() {
  echo "$CERT" > /cert.pem
  
  echo "$GCS_SERVICE_ACCOUNT" | base64 -d > /service_account.json

  gcloud auth activate-service-account --key-file=/service_account.json
}

signing_operation() {
    mkdir release
    unzip -d release release.zip
    jq ". += {\"update_url\": \"${EXTENSION_UPDATE_URL}\"}" release/manifest.json > temp.json
    mv temp.json release/manifest.json
    xvfb-run chromium --disable-gpu --disable-dev-shm-usage --no-sandbox --pack-extension=./release --pack-extension-key=/cert.pem || true
    gsutil cp ./release.crx ${TARGET_GCS_URL}
}

main

exit
