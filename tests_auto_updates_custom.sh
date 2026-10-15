#!/bin/bash

PASS_COUNT=0
WARN_COUNT=0
TOTAL_CHECKS=0

pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

warn() {
    echo "[WARNING] $1"
    echo "Recommendation: $2"
    WARN_COUNT=$((WARN_COUNT + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

echo "======================================================="
echo "       LYNIS CUSTOM AUDIT TEST"
echo "======================================================="
echo "Test ID      : CUST-9001"
echo "Audit Name   : Automatic Security Updates Audit"
echo "Category     : Operating System Security"
echo "======================================================="

echo
echo "[1] Checking unattended-upgrades package..."
if dpkg-query -W -f='${Status}' unattended-upgrades 2>/dev/null | grep -q "install ok installed"; then
    pass "unattended-upgrades package is installed."
else
    warn "unattended-upgrades package is not installed." "Install it using: sudo apt install unattended-upgrades"
fi

echo
echo "[2] Checking automatic package-list updates..."
if apt-config dump 2>/dev/null | grep -Eq 'APT::Periodic::Update-Package-Lists[[:space:]]+"?(1|true)"?;'; then
    pass "Automatic package-list updates are configured."
else
    warn "Automatic package-list updates are not confirmed in the effective APT configuration." "Configure APT::Periodic::Update-Package-Lists to 1."
fi

echo
echo "[3] Checking unattended-upgrade configuration..."
if apt-config dump 2>/dev/null | grep -Eq 'APT::Periodic::Unattended-Upgrade[[:space:]]+"?(1|true)"?;'; then
    pass "Automatic unattended upgrades are configured."
else
    warn "Automatic unattended upgrades are not confirmed in the effective APT configuration." "Configure APT::Periodic::Unattended-Upgrade to 1."
fi

echo
echo "[4] Checking apt-daily-upgrade.timer..."
TIMER_STATE=$(systemctl is-enabled apt-daily-upgrade.timer 2>/dev/null)
if [ "$TIMER_STATE" = "enabled" ] || [ "$TIMER_STATE" = "static" ]; then
    pass "apt-daily-upgrade.timer is $TIMER_STATE."
else
    warn "apt-daily-upgrade.timer is not enabled or static (state: ${TIMER_STATE:-unknown})." "Inspect the timer using: systemctl status apt-daily-upgrade.timer"
fi

echo
echo "[5] Checking unattended-upgrades log..."
if [ -f /var/log/unattended-upgrades/unattended-upgrades.log ]; then
    pass "The unattended-upgrades log file exists."
else
    warn "The unattended-upgrades log file was not found." "Inspect automatic-upgrade configuration and logs after enabling the feature."
fi

echo
echo "======================================================="
echo "                 AUDIT SUMMARY"
echo "======================================================="
echo "Total Checks : $TOTAL_CHECKS"
echo "Passed       : $PASS_COUNT"
echo "Warnings     : $WARN_COUNT"

if [ "$WARN_COUNT" -eq 0 ]; then
    echo "Overall Status : PASS"
else
    echo "Overall Status : WARNING"
fi

echo "======================================================="
