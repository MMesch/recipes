#!/usr/bin/env bash
set -euo pipefail

echo "Checking Qt6Scxml static archive is well-formed"
MEMBERS=$(emar t "${PREFIX}/lib/libQt6Scxml.a")
echo "${MEMBERS}" | head
echo "${MEMBERS}" | grep -q '\.o$' \
    || { echo "libQt6Scxml.a has no object members"; exit 1; }

echo "Compile-only check that Qt6Scxml headers are usable"
WORK=$(mktemp -d)
cd "${WORK}"

cat > main.cpp <<'EOF'
#include <QScxmlStateMachine>
int main() {
    QScxmlStateMachine *m = nullptr;
    (void)m;
    return 0;
}
EOF

em++ -std=c++17 -c \
    -I"${PREFIX}/include" \
    -I"${PREFIX}/include/QtCore" \
    -I"${PREFIX}/include/QtScxml" \
    main.cpp -o main.o

test -f main.o || { echo "main.o not produced"; exit 1; }
echo "Qt6Scxml compile test OK"
