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

check_sysctl() {
    KEY="$1"
    EXPECTED="$2"
    DESCRIPTION="$3"
    RECOMMENDATION="$4"

    VALUE=$(sysctl -n "$KEY" 2>/dev/null)

    if [ -z "$VALUE" ]; then
        warn "$DESCRIPTION could not be read ($KEY)." "Verify that the kernel parameter exists and is accessible."
    elif [ "$VALUE" = "$EXPECTED" ]; then
        pass "$DESCRIPTION is $VALUE."
    else
        warn "$DESCRIPTION is $VALUE; expected $EXPECTED." "$RECOMMENDATION"
    fi
}

echo "======================================================="
echo "       LYNIS CUSTOM AUDIT TEST"
echo "======================================================="
echo "Test ID      : CUST-9002"
echo "Audit Name   : ICMP Security Configuration Audit"
echo "Category     : Network Security"
echo "======================================================="

echo
echo "[1] Checking ICMP broadcast protection..."
check_sysctl "net.ipv4.icmp_echo_ignore_broadcasts" "1" "ICMP broadcast protection" "Set net.ipv4.icmp_echo_ignore_broadcasts=1."

echo
echo "[2] Checking bogus ICMP error protection..."
check_sysctl "net.ipv4.icmp_ignore_bogus_error_responses" "1" "Bogus ICMP error protection" "Set net.ipv4.icmp_ignore_bogus_error_responses=1."

echo
echo "[3] Checking global ICMP redirect acceptance..."
check_sysctl "net.ipv4.conf.all.accept_redirects" "0" "Global ICMP redirect acceptance" "Set net.ipv4.conf.all.accept_redirects=0 if the host does not require redirects."

echo
echo "[4] Checking default ICMP redirect acceptance..."
check_sysctl "net.ipv4.conf.default.accept_redirects" "0" "Default ICMP redirect acceptance" "Set net.ipv4.conf.default.accept_redirects=0 if the host does not require redirects."

echo
echo "[5] Checking global ICMP redirect sending..."
check_sysctl "net.ipv4.conf.all.send_redirects" "0" "Global ICMP redirect sending" "Set net.ipv4.conf.all.send_redirects=0 if the host does not act as a router."

echo
echo "[6] Checking default ICMP redirect sending..."
check_sysctl "net.ipv4.conf.default.send_redirects" "0" "Default ICMP redirect sending" "Set net.ipv4.conf.default.send_redirects=0 if the host does not act as a router."

echo
echo "[7] Checking interface-specific redirect acceptance and sending..."
for FILE in /proc/sys/net/ipv4/conf/*/accept_redirects /proc/sys/net/ipv4/conf/*/send_redirects; do
    if [ -f "$FILE" ]; then
        IFACE=$(basename "$(dirname "$FILE")")
        if [ "$IFACE" = "all" ] || [ "$IFACE" = "default" ]; then
            continue
        fi
        KEY="${FILE#/proc/sys/}"
        KEY="${KEY//\//.}"
        check_sysctl "$KEY" "0" "Interface setting $KEY" "Disable redirects for this interface if they are not required."
    fi
done
echo
echo "[8] Checking reverse-path filtering..."
for KEY in net.ipv4.conf.all.rp_filter net.ipv4.conf.default.rp_filter; do
    VALUE=$(sysctl -n "$KEY" 2>/dev/null)
    if [ -z "$VALUE" ]; then
        warn "$KEY could not be read." "Verify that the kernel parameter exists and is accessible."
    elif [ "$VALUE" = "1" ] || [ "$VALUE" = "2" ]; then
        pass "$KEY is $VALUE."
    else
        warn "$KEY is $VALUE; reverse-path filtering is not enabled for this setting." "Consider rp_filter=1 for strict filtering or rp_filter=2 for loose filtering, depending on routing requirements."
    fi
done

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
