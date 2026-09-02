#!/usr/bin/env bash
set -euo pipefail

echo "Checking Qt6NetworkAuth static archive is well-formed"
MEMBERS=$(emar t "${PREFIX}/lib/libQt6NetworkAuth.a")
echo "${MEMBERS}" | head
echo "${MEMBERS}" | grep -q '\.o$' \
    || { echo "libQt6NetworkAuth.a has no object members"; exit 1; }

echo "Compile-only check that Qt6NetworkAuth headers are usable"
WORK=$(mktemp -d)
cd "${WORK}"

cat > main.cpp <<'EOF'
#include <QOAuth2AuthorizationCodeFlow>
int main() {
    QOAuth2AuthorizationCodeFlow flow;
    (void)flow;
    return 0;
}
EOF

em++ -std=c++17 -c \
    -I"${PREFIX}/include" \
    -I"${PREFIX}/include/QtCore" \
    -I"${PREFIX}/include/QtNetwork" \
    -I"${PREFIX}/include/QtNetworkAuth" \
    main.cpp -o main.o

test -f main.o || { echo "main.o not produced"; exit 1; }
echo "Qt6NetworkAuth compile test OK"
