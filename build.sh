#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"


SRC_DIR="${DIR}/src"
DIST_DIR="${DIR}/dist"
BUILD_DIR="${DIR}/.build"

MAIN_JS="${BUILD_DIR}/main.js"
MAIN_MIN_JS="${DIST_DIR}/js/main.min.js"


try() {
    "$@" || exit 1
}

# https://gist.github.com/evancz/fc6ff4995395a1643155593a182e2de7
if ! [ -x "$(command -v uglifyjs)" ]; then
  echo 'Error: need uglifyjs to be available for asset size test.'
  echo 'You can run `npm install --global uglify-js` to get it.'
  exit 1
fi

rm -rf "${DIST_DIR}"
mkdir -p \
    "${DIST_DIR}" \
    "${BUILD_DIR}" \
    "$(dirname "${MAIN_JS}")" \
    "$(dirname "${MAIN_MIN_JS}")"


echo
echo "Build Elm source files ..."
try elm make \
    --optimize \
    --output="${MAIN_JS}" \
    "${SRC_DIR}/Main.elm"


echo
echo "Minify javascript files ..."
# https://guide.elm-lang.org/optimization/asset_size.html
try uglifyjs \
    --compress \
    'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
    "${MAIN_JS}" \
| try uglifyjs --mangle \
    --output \
    "${MAIN_MIN_JS}"

echo
echo "  Initial size: $(cat "${MAIN_JS}" | wc -c) bytes  ($(basename "${MAIN_JS}"))"
echo "  Minified size: $(cat "${MAIN_MIN_JS}" | wc -c) bytes  ($(basename "${MAIN_MIN_JS}"))"
echo "  Gzipped size: $(cat "${MAIN_MIN_JS}" | gzip -c | wc -c) bytes"


echo
echo "Copy static files to ${DIST_DIR} ..."
rsync -avP \
    static/ \
    "${DIST_DIR}"/
