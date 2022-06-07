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
    echo "amending manifest"
    jq ". += {\"update_url\": \"${EXTENSION_UPDATE_URL}\"}" release/manifest.json > release/manifest.json
    echo "signing release"
    xvfb-run chromium --disable-gpu --disable-dev-shm-usage --no-sandbox --pack-extension=./release --pack-extension-key=/cert.pem || true
    echo "uploading to gcs"
    gsutil cp ./release.crx ${TARGET_GCS_URL}
    echo "uploaded"
}

main

exit