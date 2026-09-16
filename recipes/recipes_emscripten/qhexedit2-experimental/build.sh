#!/usr/bin/env bash

# Native Qt6 host tools (moc/rcc/uic/qmake6) live under BUILD_PREFIX.
export QT_HOST_PATH="${BUILD_PREFIX}"

# Qt6's QtPublicWasmToolchainHelpers.cmake — and, transitively, qmake's
# wasm-emscripten mkspec — read $EMSDK/.emscripten to discover
# LLVM/binaryen paths. emscripten-forge doesn't ship that file, so
# synthesise one (same workaround as the qt6 recipe).
export EMSDK="${EMSCRIPTEN_FORGE_EMSDK_DIR}"
export EMSDK_NODE=$(command -v node)

if [ ! -f "${EMSDK}/.emscripten" ]; then
    cat > "${EMSDK}/.emscripten" <<EOF
LLVM_ROOT = '${EMSDK}/upstream/bin'
BINARYEN_ROOT = '${EMSDK}/upstream'
EMSCRIPTEN_ROOT = 'upstream/emscripten'
NODE_JS = '${EMSDK_NODE}'
COMPILER_ENGINE = NODE_JS
JS_ENGINES = [NODE_JS]
EOF
fi

# QHexEdit2 upstream ships a qmake project. Use it directly — the
# example/qhexedit.pro pulls in both the widget sources under ../src
# and the app sources into a single executable.
mkdir "${SRC_DIR}/build" && cd "${SRC_DIR}/build"

"${PREFIX}/bin/qmake6" \
    -qtconf "${PREFIX}/bin/qt.conf" \
    "${SRC_DIR}/example/qhexedit.pro" \
    CONFIG+=release

make -j "${CPU_COUNT:-2}"

# Install the wasm artifacts into share/qhexedit2-experimental/. Binary
# name is `qhexedit` (from the .pro filename), which is what qt-wasm-runner
# will discover from share/*/*.wasm.
INSTALL_DIR="${PREFIX}/share/qhexedit2-experimental"
mkdir -p "${INSTALL_DIR}"
cp qhexedit.wasm qhexedit.js qtloader.js "${INSTALL_DIR}/"
[ -f qhexedit.html ] && cp qhexedit.html "${INSTALL_DIR}/" || true
