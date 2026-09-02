#!/usr/bin/env bash
set -euo pipefail

echo "Checking Qt6Mqtt static archive is well-formed"
MEMBERS=$(emar t "${PREFIX}/lib/libQt6Mqtt.a")
echo "${MEMBERS}" | head
echo "${MEMBERS}" | grep -q '\.o$' \
    || { echo "libQt6Mqtt.a has no object members"; exit 1; }

echo "Compile-only check that Qt6Mqtt headers are usable"
WORK=$(mktemp -d)
cd "${WORK}"

cat > main.cpp <<'EOF'
#include <QMqttClient>
int main() {
    QMqttClient c;
    (void)c;
    return 0;
}
EOF

em++ -std=c++17 -c \
    -I"${PREFIX}/include" \
    -I"${PREFIX}/include/QtCore" \
    -I"${PREFIX}/include/QtNetwork" \
    -I"${PREFIX}/include/QtMqtt" \
    main.cpp -o main.o

test -f main.o || { echo "main.o not produced"; exit 1; }
echo "Qt6Mqtt compile test OK"
