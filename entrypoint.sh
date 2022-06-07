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
    echo "making directory"
    mkdir release
    echo "unzipping release"
    unzip -d release release.zip
    echo "jq \". += {\\\"update_url\\\": \\\"${EXTENSION_UPDATE_URL}\\\"}\" release/manifest.json > release/manifest.json"
    jq ". += {\"update_url\": \"${EXTENSION_UPDATE_URL}\"}" release/manifest.json > release/manifest.json
    echo "signing release"
    ls -lathr
    xvfb-run chromium --disable-gpu --disable-dev-shm-usage --no-sandbox --pack-extension=./release --pack-extension-key=/cert.pem || true
    ls -lathr
    sleep 1
    ls -lathr
    sleep 1
    ls -lathr
    sleep 1
    ls -lathr
    sleep 1
    echo "gsutil cp ./release.crx ${TARGET_GCS_URL}"
    gsutil cp ./release.crx ${TARGET_GCS_URL}
    echo "uploaded"
}

main

exit