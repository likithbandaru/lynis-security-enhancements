
#!/bin/bash

PASS_COUNT=0
WARN_COUNT=0
TOTAL_CHECKS=0

pass() {
    echo "  - $1 [ OK ]"
    PASS_COUNT=$((PASS_COUNT + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

warn() {
    echo "  - $1 [ WARNING ]"
    WARN_COUNT=$((WARN_COUNT + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

echo
echo "[+] LYNIS CUSTOM AUDIT TEST"
echo "Test ID     : CUST-9001"
echo "Audit Name  : Automatic Security Updates Audit"
echo "=============================================="

if dpkg-query -W -f='${Status}' unattended-upgrades 2>/dev/null | grep -q "install ok installed"; then
    pass "Unattended-upgrades package installed"
else
    warn "Unattended-upgrades package not installed"
fi

if apt-config dump 2>/dev/null | grep -Eq 'APT::Periodic::Update-Package-Lists[[:space:]]+"?(1|true)"?;'; then
    pass "Automatic package-list updates configured"
else
    warn "Automatic package-list updates not configured"
fi

if apt-config dump 2>/dev/null | grep -Eq 'APT::Periodic::Unattended-Upgrade[[:space:]]+"?(1|true)"?;'; then
    pass "Automatic unattended upgrades configured"
else
    warn "Automatic unattended upgrades not configured"
fi

TIMER_STATE=$(systemctl is-enabled apt-daily-upgrade.timer 2>/dev/null)

if [ "$TIMER_STATE" = "enabled" ] || [ "$TIMER_STATE" = "static" ]; then
    pass "APT upgrade timer enabled"
else
    warn "APT upgrade timer not enabled"
fi

if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
    pass "Unattended-upgrades log available"
else
    warn "Unattended-upgrades log not found"
fi

echo "=============================================="
echo "AUDIT SUMMARY"
echo "=============================================="
echo "Total Checks : $TOTAL_CHECKS"
echo "Passed       : $PASS_COUNT"
echo "Warnings     : $WARN_COUNT"

if [ "$WARN_COUNT" -eq 0 ]; then
    echo "Overall Status : PASS"
else
    echo "Overall Status : WARNING"
fi

echo "=============================================="
