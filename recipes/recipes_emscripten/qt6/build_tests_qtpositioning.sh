#!/usr/bin/env bash
set -euo pipefail

echo "Checking Qt6Positioning static archive is well-formed"
MEMBERS=$(emar t "${PREFIX}/lib/libQt6Positioning.a")
echo "${MEMBERS}" | head
echo "${MEMBERS}" | grep -q '\.o$' \
    || { echo "libQt6Positioning.a has no object members"; exit 1; }

echo "Compile-only check that Qt6Positioning headers are usable"
WORK=$(mktemp -d)
cd "${WORK}"

cat > main.cpp <<'EOF'
#include <QGeoPositionInfoSource>
int main() {
    QGeoPositionInfoSource *s = nullptr;
    (void)s;
    return 0;
}
EOF

em++ -std=c++17 -c \
    -I"${PREFIX}/include" \
    -I"${PREFIX}/include/QtCore" \
    -I"${PREFIX}/include/QtPositioning" \
    main.cpp -o main.o

test -f main.o || { echo "main.o not produced"; exit 1; }
echo "Qt6Positioning compile test OK"
