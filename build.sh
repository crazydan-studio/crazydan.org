#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"


SRC_DIR="${DIR}/src"
DIST_DIR="${DIR}/dist"


try() {
    "$@" || exit 1
}

echo
echo "Build Elm source files ..."
try elm make \
    --optimize \
    --output="${DIST_DIR}/js/main.js" \
    "${SRC_DIR}/Main.elm"


echo
echo "Minify javascript files ..."
# https://guide.elm-lang.org/optimization/asset_size.html
try uglifyjs \
    --compress \
    'pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe' \
    "${DIST_DIR}/js/main.js" \
| try uglifyjs --mangle \
    --output \
    "${DIST_DIR}/js/main.min.js" \
&& rm -f "${DIST_DIR}/js/main.js"


echo
echo "Copy static files to ${DIST_DIR} ..."
rsync -avP \
    static/ \
    "${DIST_DIR}"/
