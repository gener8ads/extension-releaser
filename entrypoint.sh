#!/bin/sh

set -e

main() {
    launch_xvfb
    launch_window_manager
    signing_operation
}

launch_xvfb() {
    # Set defaults if the user did not specify envs.
    export DISPLAY=${XVFB_DISPLAY:-:1}
    local screen=${XVFB_SCREEN:-0}
    local resolution=${XVFB_RESOLUTION:-1280x1024x24}
    local timeout=${XVFB_TIMEOUT:-5}

    # Start and wait for either Xvfb to be fully up or we hit the timeout.
    Xvfb ${DISPLAY} -screen ${screen} ${resolution} &
    local loopCount=0
    until xdpyinfo -display ${DISPLAY} > /dev/null 2>&1
    do
        loopCount=$((loopCount+1))
        sleep 1
        if [ ${loopCount} -gt ${timeout} ]
        then
            echo "${G_LOG_E} xvfb failed to start."
            exit 1
        fi
    done
}

launch_window_manager() {
    local timeout=${XVFB_TIMEOUT:-5}

    # Start and wait for either fluxbox to be fully up or we hit the timeout.
    fluxbox &
    local loopCount=0
    until wmctrl -m > /dev/null 2>&1
    do
        loopCount=$((loopCount+1))
        sleep 1
        if [ ${loopCount} -gt ${timeout} ]
        then
            echo "${G_LOG_E} fluxbox failed to start."
            exit 1
        fi
    done
}

signing_operation() {
    echo "making directory"
    mkdir release
    echo "unzipping release"
    unzip -d release release.zip
    echo "amending manifest"
    jq ". += {\"update_url\": \"${EXTENSION_UPDATE_URL}\"}" release/manifest.json > release/manifest.json
    echo "signing release"
    google-chrome-stable --no-sandbox --pack-extension=release --pack-extension-key=/cert.pem
    echo "uploading to gcs"
    ./gsutil/gsutil cp ./release.crx ${TARGET_GCS_URL}
    echo "uploaded"
}

main

exit