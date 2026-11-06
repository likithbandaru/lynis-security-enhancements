
#!/bin/bash

TOTAL=0
PASSED=0
WARNINGS=0

echo
echo "[+] AUTOMATIC UPDATE SERVICE STATUS AUDIT"
echo "Test ID       : CUST-9003"
echo "Reference Test: PKGS-7420"
echo "=============================================="

check() {
    TOTAL=$((TOTAL + 1))

    if [ "$2" = "$3" ]; then
        echo "  - $1 [ OK ]"
        PASSED=$((PASSED + 1))
    else
        echo "  - $1 [ WARNING ]"
        WARNINGS=$((WARNINGS + 1))
    fi
}

PACKAGE=$(dpkg-query -W -f='${Status}' unattended-upgrades 2>/dev/null)

if [ "$PACKAGE" = "install ok installed" ]; then
    PACKAGE="installed"
else
    PACKAGE="not installed"
fi

check "Unattended-upgrades package" "$PACKAGE" "installed"

for TIMER in apt-daily.timer apt-daily-upgrade.timer
do
    ENABLED=$(systemctl is-enabled "$TIMER" 2>/dev/null)
    ACTIVE=$(systemctl is-active "$TIMER" 2>/dev/null)

    [ -n "$ENABLED" ] || ENABLED="not found"
    [ -n "$ACTIVE" ] || ACTIVE="not found"

    check "$TIMER enabled" "$ENABLED" "enabled"
    check "$TIMER active" "$ACTIVE" "active"
done

SERVICE=$(systemctl is-failed apt-daily-upgrade.service 2>/dev/null)
[ -n "$SERVICE" ] || SERVICE="unknown"

check "APT upgrade service failure status" "$SERVICE" "inactive"

echo "=============================================="
echo "AUDIT SUMMARY"
echo "=============================================="
echo "Total Checks : $TOTAL"
echo "Passed       : $PASSED"
echo "Warnings     : $WARNINGS"

if [ "$WARNINGS" -eq 0 ]; then
    echo "Overall Status : PASS"
else
    echo "Overall Status : WARNING"
fi

echo "=============================================="
