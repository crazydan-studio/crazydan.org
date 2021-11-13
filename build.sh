#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"


SRC_DIR="${DIR}/src"
DIST_DIR="${DIR}/dist"


echo
echo "Build Elm source files ..."
elm make \
    --optimize \
    --output="${DIST_DIR}/js/main.js" \
    "${SRC_DIR}/Main.elm" \
|| exit 1


echo
echo "Copy static file to ${DIST_DIR} ..."
rsync -avP \
    asset index.html \
    "${DIST_DIR}"/
