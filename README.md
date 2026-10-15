# Lynis Security Enhancements

This repository contains two custom Bash audit scripts developed for a Linux security auditing assignment.

## Scripts

### 1. Automatic Security Updates Audit
File: tests_auto_updates_custom.sh

Test ID: CUST-9001

Checks package installation, effective APT automatic-update settings, the APT upgrade timer, and the unattended-upgrades log file.

### 2. ICMP Security Configuration Audit
File: tests_icmp_security_custom.sh

Test ID: CUST-9002

Checks ICMP broadcast protection, bogus ICMP error protection, redirect settings, interface-specific redirect settings, and reverse-path filtering.

## Running the Scripts

Run each script using Bash:

```bash
sudo bash tests_auto_updates_custom.sh
sudo bash tests_icmp_security_custom.sh
## Notes

These are standalone Bash audit scripts. They report PASS and WARNING results and provide recommendations. They do not automatically modify system security settings.

Results depend on the system configuration being audited.
